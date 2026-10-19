$ErrorActionPreference="Stop"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    if(-not (Test-Path sim/bass_work)) { & vlib sim/bass_work }
    & vlog -sv -work sim/bass_work src/adsr_step.v src/output_limiter.v src/piano_synth.v sim/tb_bass.sv
    if($LASTEXITCODE -ne 0) { throw "Bass compilation failed" }
    & vsim -c -lib sim/bass_work tb_bass -do 'onfinish stop; run -all; quit -code 0 -f' -l sim/tb_bass.log
    if($LASTEXITCODE -ne 0) { throw "Bass comparison failed" }
    # This optimized render omits +acc. Inspect its explicit terminal PASS
    # marker instead of trying to examine a register optimized out by vopt.
    if(-not (Select-String -Path sim/tb_bass.log -Pattern '^# PASS tb_bass: 216000 ' -Quiet)) {
        throw "Bass render did not reach successful completion"
    }
    & python tools/analyze_bass.py
    if($LASTEXITCODE -ne 0) { throw "Bass analysis failed" }
} finally { Pop-Location }
