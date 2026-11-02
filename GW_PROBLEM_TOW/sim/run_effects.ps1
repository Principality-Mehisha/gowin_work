$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python -B tools/effects_reference.py
    if($LASTEXITCODE){throw 'Effect reference failed'}
    & python -B tools/make_upload_fixtures.py
    if($LASTEXITCODE){throw 'Slot fixtures failed'}
    $out='output/audio_effects'
    if(-not(Test-Path "$out/work")) { & vlib "$out/work"; if($LASTEXITCODE){throw 'vlib failed'} }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/tb_audio_effects.sv sim/tb_effects_integration.sv sim/tb_tjc_status.sv sim/tb_uart_protocol.sv sim/tb_fixed_slot_reader.sv
    if($LASTEXITCODE){throw 'Effects simulation compilation failed'}
    foreach($bench in @('tb_audio_effects','tb_tjc_status','tb_uart_protocol','tb_effects_integration','tb_fixed_slot_reader')) {
        $extra=@();if($bench -eq 'tb_uart_protocol'){$extra=@('-gUART_TICKS=8')}
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench @extra -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    & python -B tools/check_effects.py
    if($LASTEXITCODE){throw 'Effects evidence check failed'}
} finally { Pop-Location }
