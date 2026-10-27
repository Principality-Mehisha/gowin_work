param([string]$PythonExe='python')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    & $PythonExe tools/check_project.py
    if($LASTEXITCODE -ne 0){throw 'Project check failed'}
    & $PythonExe tools/make_video_fixtures.py
    if($LASTEXITCODE -ne 0){throw 'Video reference generation failed (NumPy/Pillow required)'}
    & $PythonExe tools/make_test_fixtures.py
    if($LASTEXITCODE -ne 0){throw 'SD fixture generation failed'}
    if(-not(Test-Path sim/video_work)){ & vlib sim/video_work }
    if($LASTEXITCODE -ne 0){throw 'vlib failed'}
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work sim/video_work @sources sim/sd_card_model.v sim/tb_uart_player.sv sim/tb_video_player.sv sim/tb_video_sync.sv sim/tb_video_timeline.sv sim/tb_video_scene.sv sim/tb_video_line.sv sim/tb_video_raster.sv sim/tb_video_tmds.sv
    if($LASTEXITCODE -ne 0){throw 'Video compilation failed'}
    foreach($bench in @('tb_video_sync','tb_video_timeline','tb_video_scene','tb_video_line','tb_video_raster','tb_tmds','tb_video_player')){
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/video_work $bench -do $commands -l "output/video_integration/$bench.log"
        if($LASTEXITCODE -ne 0){throw "$bench failed"}
    }
    & $PythonExe tools/check_video_image.py
    if($LASTEXITCODE -ne 0){throw 'Video pixel comparison failed'}
} finally { Pop-Location }
