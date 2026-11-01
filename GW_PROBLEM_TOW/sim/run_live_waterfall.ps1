$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python -B tools/make_upload_fixtures.py
    if($LASTEXITCODE){throw 'SD fixtures failed'}
    & python -B tools/live_waterfall_reference.py
    if($LASTEXITCODE){throw 'Live image fixtures failed'}
    $out='output/live_waterfall'
    New-Item -ItemType Directory -Force $out | Out-Null
    if(-not(Test-Path "$out/work")){ & vlib "$out/work"; if($LASTEXITCODE){throw 'vlib failed'} }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/tb_uart_player.sv sim/tb_video_player.sv sim/tb_uart_notes.sv sim/tb_pressure_integration.sv sim/tb_live_waterfall.sv sim/tb_live_waterfall_scene.sv sim/tb_video_sync.sv
    if($LASTEXITCODE){throw 'Live waterfall compilation failed'}
    foreach($bench in @('tb_live_waterfall','tb_live_waterfall_scene','tb_video_sync','tb_uart_notes','tb_video_player','tb_pressure_integration')) {
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    & python -B tools/live_waterfall_reference.py --check
    if($LASTEXITCODE){throw 'Live waterfall image/evidence check failed'}
} finally { Pop-Location }
