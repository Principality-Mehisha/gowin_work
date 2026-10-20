$ErrorActionPreference="Stop"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    if(-not (Test-Path sim/work)) { & vlib sim/work }
    & vlog -sv -work sim/work src/adsr_step.v src/output_limiter.v src/piano_synth.v src/pt8211_score_tx.v sim/tb_synth.sv
    if($LASTEXITCODE -ne 0) { throw "Waveform test compilation failed" }
    & vsim -voptargs=+acc -lib sim/work tb_synth -do sim/waves.do
} finally { Pop-Location }
