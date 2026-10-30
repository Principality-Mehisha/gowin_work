param([string]$PythonExe='python', [string[]]$Benches=@('tb_audio_analysis','tb_analysis_cdc','tb_piano_views','tb_analysis_render','tb_uart_protocol','tb_uart_notes','tb_uart_player','tb_video_player','tb_video_raster','tb_video_sync','tb_tmds','tb_video_scene'), [switch]$SkipHardware)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & $PythonExe tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & $PythonExe tools/make_analysis_fixtures.py
    if($LASTEXITCODE){throw 'Analysis fixtures failed'}
    & $PythonExe tools/make_test_fixtures.py
    if($LASTEXITCODE){throw 'SD/UART fixtures failed'}
    $renderPython=$PythonExe
    if('tb_video_scene' -in $Benches) {
        & $renderPython -c "import importlib.util,sys;sys.exit(0 if all(importlib.util.find_spec(n) for n in ('numpy','PIL')) else 1)"
        if($LASTEXITCODE) {
            $bundledPython=Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'
            if(-not(Test-Path $bundledPython)){throw 'Waterfall reference needs NumPy/Pillow; pass -PythonExe with those libraries'}
            $renderPython=$bundledPython
        }
        & $renderPython tools/make_video_fixtures.py
        if($LASTEXITCODE){throw 'Waterfall reference generation failed'}
    }
    $out='output/piano_analysis'
    if(-not(Test-Path "$out/work")){ & vlib "$out/work" }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/tb_audio_analysis.sv sim/tb_analysis_cdc.sv sim/tb_piano_views.sv sim/tb_analysis_render.sv sim/tb_uart_player.sv sim/tb_video_player.sv sim/tb_uart_protocol.sv sim/tb_uart_notes.sv sim/tb_video_raster.sv sim/tb_video_sync.sv sim/tb_video_scene.sv sim/tb_video_tmds.sv
    if($LASTEXITCODE){throw 'Analysis compilation failed'}
    foreach($bench in $Benches) {
        if($bench -eq 'tb_analysis_render') {
            & $PythonExe tools/check_analysis.py --prepare-render
            if($LASTEXITCODE){throw 'Real piano analysis differs'}
        }
        $extra=@();if($bench -eq 'tb_uart_protocol'){$extra=@('-gUART_TICKS=8')}
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench @extra -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    if('tb_video_scene' -in $Benches) {
        & $renderPython tools/check_video_image.py
        if($LASTEXITCODE){throw 'Waterfall image differs'}
    }
    if(-not $SkipHardware) {
        & sim/run_video_hardware.ps1
        if($LASTEXITCODE){throw 'Official video model regression failed'}
        Copy-Item -LiteralPath output/video_integration/tb_video_hardware.log -Destination "$out/tb_video_hardware.log"
    }
    & $PythonExe tools/check_analysis.py
    if($LASTEXITCODE){throw 'Analysis image/data verification failed'}
}finally{Pop-Location}
