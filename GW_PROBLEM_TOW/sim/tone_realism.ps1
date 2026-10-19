$ErrorActionPreference="Stop"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    if(-not (Test-Path sim/tone_work)) { & vlib sim/tone_work }
    & vlog -sv -work sim/tone_work src/adsr_step.v src/output_limiter.v `
        src/piano_synth.v sim/tb_tone_realism.sv
    if($LASTEXITCODE -ne 0) { throw "Tone realism compile failed" }
    & vsim -c -lib sim/tone_work tb_tone_realism `
        -do 'onfinish stop; run -all; quit -code 0 -f' -l sim/tone_realism.log
    if($LASTEXITCODE -ne 0) { throw "Tone realism render failed" }
    if(-not (Select-String -Path sim/tone_realism.log `
        -Pattern '^# PASS tb_tone_realism: 42000 ' -Quiet)) {
        throw "Tone realism render did not reach successful completion"
    }
    & python tools/analyze_tone_realism.py
    if($LASTEXITCODE -ne 0) { throw "Tone realism analysis failed" }
} finally { Pop-Location }
