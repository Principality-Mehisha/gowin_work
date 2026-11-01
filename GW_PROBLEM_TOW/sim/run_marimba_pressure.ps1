$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    $out='output/marimba_pressure'
    New-Item -ItemType Directory -Force $out | Out-Null
    if(-not(Test-Path "$out/work")) { & vlib "$out/work"; if($LASTEXITCODE){throw 'vlib failed'} }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/tb_marimba_mapping.sv sim/tb_marimba_pressure.sv sim/tb_marimba.sv sim/tb_instrument_bank.sv sim/tb_analysis_render.sv
    if($LASTEXITCODE){throw 'Marimba simulation compilation failed'}
    foreach($bench in @('tb_marimba_mapping','tb_marimba','tb_instrument_bank','tb_marimba_pressure')) {
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    & python -B tools/check_analysis.py --data-dir $out --prefix marimba --prepare-render
    if($LASTEXITCODE){throw 'Real marimba PCM analysis differs from reference'}
    $commands='onfinish stop; run -all; if {[examine -radix unsigned /tb_analysis_render/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
    & vsim -c -voptargs=+acc -lib "$out/work" tb_analysis_render "-gDATA_FILE=$out/render_data.hex" "-gSPECTRUM_FILE=$out/spectrum.ppm" "-gWAVEFORM_FILE=$out/waveform.ppm" -do $commands -l "$out/tb_analysis_render.log"
    if($LASTEXITCODE){throw 'Marimba RGB render failed'}
    & python -B tools/check_analysis.py --data-dir $out --prefix marimba
    if($LASTEXITCODE){throw 'Marimba RGB pixels differ from reference'}
} finally { Pop-Location }
