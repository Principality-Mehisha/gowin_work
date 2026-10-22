$ErrorActionPreference = "Stop"
$projectPath = Split-Path -Parent $PSScriptRoot
Push-Location $projectPath
try {
    if (-not (Test-Path sim/work)) {
        & vlib sim/work
        if ($LASTEXITCODE -ne 0) { throw "vlib failed" }
    }
    $sources = @("src/adsr_step.v", "src/output_limiter.v", "src/piano_synth.v",
        "src/uart_rx.v", "src/uart_tx.v", "src/tjc_status_tx.v", "src/uart_score_control.v",
        "src/uart_note_audition.v",
        "src/marimba_synth.v", "src/marimba_body_filter.v", "src/ringtone_pcm_player.v",
        "src/dynamics_fixed.v", "src/key_control.v",
        "src/pt8211_score_tx.v", "src/piano_score_player.v", "src/button_debounce.v",
        "src/sd_spi_byte.v", "src/sd_spi_reader.v", "src/fat_file_reader.v",
        "src/piano_score_reader.v", "src/piano_score_sequencer.v",
        "sim/tb_marimba_controls.sv", "sim/tb_synth.sv", "sim/tb_marimba.sv",
        "sim/tb_keys.sv", "sim/tb_dac.sv", "sim/tb_limiter.sv", "sim/tb_ringtone.sv")
    & vlog -sv +incdir+src -work sim/work @sources
    if ($LASTEXITCODE -ne 0) { throw "vlog failed" }
    foreach ($bench in @("tb_keys", "tb_limiter", "tb_dac", "tb_synth", "tb_marimba", "tb_ringtone", "tb_marimba_controls")) {
        $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' +
            $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/work $bench -do $commands -l "sim/${bench}.log"
        if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
    }
} finally {
    Pop-Location
}
