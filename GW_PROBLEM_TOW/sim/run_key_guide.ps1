$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python -B tools/make_upload_fixtures.py
    if($LASTEXITCODE){throw 'Existing fixtures failed'}
    & python -B tools/make_key_guide_fixtures.py
    if($LASTEXITCODE){throw 'Guide fixtures failed'}
    $out='output/key_guide'
    if(-not(Test-Path "$out/work")) { & vlib "$out/work"; if($LASTEXITCODE){throw 'vlib failed'} }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/ws2812_monitor.sv sim/tb_key_guide.sv sim/tb_key_guide_integration.sv sim/tb_board_controls.sv sim/tb_pressure_integration.sv sim/tb_uart_player.sv sim/tb_video_player.sv
    if($LASTEXITCODE){throw 'Guide simulation compilation failed'}
    foreach($bench in @('tb_key_guide','tb_key_guide_integration','tb_board_controls',
                        'tb_pressure_integration','tb_uart_player','tb_video_player')) {
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    & python -B tools/check_key_guide.py
    if($LASTEXITCODE){throw 'Guide evidence failed'}
} finally { Pop-Location }
