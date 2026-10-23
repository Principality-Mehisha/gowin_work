$ErrorActionPreference="Stop"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    if(-not (Test-Path sim/work)) { & vlib sim/work }
    & vlog -sv -work sim/work src/audio/adsr_pipeline.v src/audio/output_limiter.v src/audio/piano_synth.v src/audio/pt8211_score_tx.v sim/tb_demo.sv
    if($LASTEXITCODE -ne 0) { throw "Demo compilation failed" }
    & vsim -c -voptargs=+acc -lib sim/work tb_demo -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_demo/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l sim/tb_demo.log
    if($LASTEXITCODE -ne 0) { throw "Demo failed" }
    & python tools/analyze_audio.py
    if($LASTEXITCODE -ne 0) { throw "Audio analysis failed" }
} finally { Pop-Location }
