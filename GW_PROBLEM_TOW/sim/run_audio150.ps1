param([string[]]$Benches=@('tb_audio150_ip','tb_audio150_core','tb_audio150_bridge','tb_audio150_effects','tb_audio150_system'))
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    if('tb_audio150_system' -in $Benches){
        & python -B tools/make_key_guide_fixtures.py
        if($LASTEXITCODE){throw 'Native SD fixtures failed'}
    }
    $out='output/audio150/work'
    if(-not(Test-Path $out)){& vlib $out;if($LASTEXITCODE){throw 'vlib failed'}}
    $sources=Get-ProjectSources $projectRoot
    $tests=@(Get-ChildItem -LiteralPath sim -Filter 'tb_audio150_*.sv' | ForEach-Object {$_.FullName})
    & vlog -sv +incdir+sim -work $out @sources sim/sd_card_model.v sim/ws2812_monitor.sv sim/tb_analysis_render.sv @tests
    if($LASTEXITCODE){throw 'Native audio simulation compile failed'}
    foreach($bench in $Benches){
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib $out $bench -do $commands -l "output/audio150/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    if('tb_audio150_core' -in $Benches){
        & python -B tools/check_audio150_samples.py
        if($LASTEXITCODE){throw 'Native PCM reference failed'}
    }
    if('tb_audio150_system' -in $Benches){
        & python -B tools/check_analysis.py --data-dir output/audio150 --rate-ratio 3 --prepare-render
        if($LASTEXITCODE){throw 'Native DAC FFT reference failed'}
        & vsim -c -voptargs=+acc -lib $out tb_analysis_render -gANALYSIS_RATE_RATIO=3 "-gDATA_FILE=output/audio150/render_data.hex" "-gSPECTRUM_FILE=output/audio150/spectrum.ppm" "-gWAVEFORM_FILE=output/audio150/waveform.ppm" -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_analysis_render/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l output/audio150/tb_analysis_render.log
        if($LASTEXITCODE){throw 'Native video render failed'}
        & python -B tools/check_analysis.py --data-dir output/audio150 --rate-ratio 3
        if($LASTEXITCODE){throw 'Native video reference failed'}
    }
    if(@('tb_audio150_ip','tb_audio150_core','tb_audio150_bridge','tb_audio150_effects','tb_audio150_system' |
        Where-Object {$_ -notin $Benches}).Count -eq 0){
        & python -B tools/check_audio150.py
        if($LASTEXITCODE){throw 'Native audio evidence/source audit failed'}
    }
}finally{Pop-Location}
