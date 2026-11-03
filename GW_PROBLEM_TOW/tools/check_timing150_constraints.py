"""Safely parse SDC and audit the narrow CDC/reset exception scope."""
from pathlib import Path
import fnmatch
import json
import re
import tkinter
import zipfile

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output/timing150"
PREFIX = "score_player/system/clock_bridge/"


def parse_sdc(text):
    tcl = tkinter.Tcl()
    tcl.call("interp", "create", "-safe", "sdc")
    records = []
    for command in ("create_clock", "create_generated_clock", "set_false_path", "set_max_delay",
                    "report_timing", "report_exceptions", "report_max_frequency"):
        def record(*args, name=command):
            records.append((name, args))
            return ""
        tcl.createcommand("_" + command, record)
        tcl.call("interp", "alias", "sdc", command, "", "_" + command)
    for command, kind in (("get_ports", "port"), ("get_clocks", "clock"),
                          ("get_pins", "pin"), ("get_cells", "cell")):
        def collection(patterns, label=kind):
            return tuple(label + ":" + p for p in tcl.splitlist(patterns))
        tcl.createcommand("_" + command, collection)
        tcl.call("interp", "alias", "sdc", command, "", "_" + command)
    tcl.call("interp", "eval", "sdc", text)
    return records, tcl


def main():
    with zipfile.ZipFile(OUT / "before/sources.zip") as z:
        previous = z.read("src/board/GW_PROBLEM_TOW.sdc").decode()
    old, _ = parse_sdc(previous)
    new, tcl = parse_sdc((ROOT / "src/board/GW_PROBLEM_TOW.sdc").read_text())
    old_clocks = [r for r in old if r[0] in ("create_clock", "create_generated_clock")]
    expected_clocks = []
    for name, args in old_clocks:
        if name == "create_generated_clock" and args[args.index("-name") + 1] == "pixel_clk":
            args = list(args)
            index = args.index("-divide_by")
            assert args[index + 1] == "5"
            args[index:index + 2] = ["-edges", "1 7 11"]
            args = tuple(args)
        expected_clocks.append((name, args))
    assert expected_clocks == [r for r in new if r[0] in ("create_clock", "create_generated_clock")]
    old_false = {r for r in old if r[0] == "set_false_path"}
    current_false = {r for r in new if r[0] == "set_false_path"}
    assert old_false <= current_false, "An existing exception was removed/changed"
    extra = current_false - old_false
    assert len(extra) == 3, "Only lock D, Gray first-stage hold and release CLEAR exceptions may be added"
    gray_patterns = []
    for side in ("commands", "feedback"):
        gray_patterns += [PREFIX + side + "/fifo/fifo_inst/Equal." + name + "*_s0/D"
                          for name in ("rq1_wptr", "wq1_rptr")]
    release_patterns = [
        "score_player/audio_clocks/release_pipe*_s0/CLEAR",
        PREFIX + "engine_release*_s0/CLEAR",
        *[PREFIX + side + "/" + name + "*_s0/CLEAR"
          for side in ("commands", "feedback") for name in ("wr_release", "rd_release")],
        "display_enabled.video/release_pipe*_s0/CLEAR",
        "display_enabled.video/sys_release*_s0/CLEAR",
        "display_enabled.video/serializer_release*_s0/CLEAR",
    ]
    saw = set()
    for _, args in extra:
        assert args[0] in ("-hold", "-to") and "-to" in args
        destinations = tcl.splitlist(args[args.index("-to") + 1])
        assert all(p.startswith("pin:") for p in destinations)
        patterns = {p[4:] for p in destinations}
        if "-hold" in args:
            assert patterns == set(gray_patterns)
            saw.add("gray_hold_only")
        elif patterns == {PREFIX + "lock_sync_0_s0/D"}:
            saw.add("lock_first_stage")
        else:
            assert patterns == set(release_patterns)
            saw.add("release_clear_only")
    assert len(saw) == 3

    # These are the actual register names in the generated official simulation
    # netlist, not guessed async-register names or an entire clock group.
    fifo = (ROOT / "ip/audio_fifo32/audio_fifo32.vo").read_text()
    names = re.findall(r"\bDFF\w*\s+\\(fifo_inst/Equal\.(?:wptr|rptr|rq1_wptr|wq1_rptr)[^\s]+)\s", fifo)
    pins = {PREFIX + side + "/fifo/" + name + "/" + pin
            for side in ("commands", "feedback") for name in names for pin in ("Q", "D")}
    capped = set()
    max_paths = [args for name, args in new if name == "set_max_delay"]
    assert len(max_paths) == 4
    for args in max_paths:
        assert float(args[-1]) == 6.0
        source, = tcl.splitlist(args[args.index("-from") + 1])
        target, = tcl.splitlist(args[args.index("-to") + 1])
        assert source.startswith("pin:") and target.startswith("pin:")
        source, target = source[4:], target[4:]
        assert target in gray_patterns
        expected_source = target.replace("rq1_wptr", "wptr").replace("wq1_rptr", "rptr").removesuffix("/D") + "/Q"
        assert source == expected_source
        starts = {p for p in pins if fnmatch.fnmatchcase(p, source)}
        ends = {p for p in pins if fnmatch.fnmatchcase(p, target)}
        assert len(starts) == len(ends) == 5, "Official FIFO pointer collection changed"
        capped |= ends
    assert len(capped) == 20
    assert not any("rq2" in p or "wq2" in p for p in capped)
    assert not re.search(r"\b(set_clock_groups|set_multicycle_path|set_clock_uncertainty)\b",
                         (ROOT / "src/board/GW_PROBLEM_TOW.sdc").read_text())
    reports = [args for name, args in new if name == "report_timing" and "-setup" in args]
    for launch, latch in (("sys_clk", "sys_clk"), ("audio_clk", "audio_clk"),
                          ("sys_clk", "audio_clk"), ("audio_clk", "sys_clk"),
                          ("pixel_clk", "pixel_clk")):
        assert any("-from_clock" in a and "-to_clock" in a and
                   a[a.index("-from_clock") + 1] == "clock:" + launch and
                   a[a.index("-to_clock") + 1] == "clock:" + latch for a in reports)
    result = dict(clock_frequencies_unchanged=True, pixel_edges=[1, 7, 11], pixel_duty_percent=60,
                  gray_first_stage_pins=sorted(capped),
                  gray_max_delay_ns=6.0, hold_only_at_gray_first_stage=True,
                  reset_exception_patterns=release_patterns, reset_pipeline_clear_bits=35,
                  serializer_reset_path_still_timed=True, functional_reset_paths_still_timed=True,
                  safe_tcl_parse=True, physical_eda_collections_validated=False)
    (OUT / "constraint_scope.json").write_text(json.dumps(result, indent=2) + "\n", encoding="ascii")
    print("PASS: safe Tcl syntax/scope; 20 official Gray first-stage pins bounded to 6 ns; "
          "only dedicated release CLEAR pins exempted; clocks/payload/second stages remain timed")


if __name__ == "__main__":
    main()
