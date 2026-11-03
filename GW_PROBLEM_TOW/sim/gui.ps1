$ErrorActionPreference="Stop"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    if(-not (Test-Path sim/work)) { & vlib sim/work }
    & vlog -sv -work sim/work src/audio/adsr_pipeline.v src/audio/output_limiter.v src/audio/sine_pair_rom.v src/audio/piano_synth.v src/audio/pt8211_score_tx.v sim/tb_synth.sv
    if($LASTEXITCODE -ne 0) { throw "Waveform test compilation failed" }
    & vsim -voptargs=+acc -lib sim/work tb_synth -do sim/waves.do
} finally { Pop-Location }
