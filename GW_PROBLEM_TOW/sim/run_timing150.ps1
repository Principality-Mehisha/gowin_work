param([string[]]$Benches=@('tb_audio_effects','tb_audio150_effects','tb_timing150_effects',
    'tb_audio150_ip','tb_audio150_bridge','tb_video_hardware','tb_serializer_reset','tb_analysis_cdc'),
    [switch]$Full)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python -B tools/effects_reference.py
    if($LASTEXITCODE){throw 'Effect reference failed'}
    $out='output/timing150'
    if(-not(Test-Path -LiteralPath "$out/before/audio_effects_before.v")){
        throw 'Missing pre-timing frozen source; do not regenerate from modified RTL'
    }
    & python -B tools/check_timing150_constraints.py
    if($LASTEXITCODE){throw 'SDC scope/syntax audit failed'}
    if(-not(Test-Path -LiteralPath "$out/work")){& vlib "$out/work";if($LASTEXITCODE){throw 'vlib failed'}}
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources "$out/before/audio_effects_before.v" `
        sim/tb_audio_effects.sv sim/tb_audio150_effects.sv sim/tb_timing150_effects.sv `
        sim/tb_audio150_ip.sv sim/tb_audio150_bridge.sv sim/tb_video_hardware.sv `
        sim/tb_serializer_reset.sv sim/tb_analysis_cdc.sv
    if($LASTEXITCODE){throw 'Timing-refactor simulation compile failed'}
    foreach($bench in $Benches){
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    if($Full){
        & sim/run_audio150.ps1 -Benches @('tb_audio150_system')
        if($LASTEXITCODE){throw 'Native top-level regression failed'}
    }
    if(@('tb_audio_effects','tb_audio150_effects','tb_timing150_effects','tb_audio150_ip',
        'tb_audio150_bridge','tb_video_hardware','tb_serializer_reset','tb_analysis_cdc' |
        Where-Object {$_ -notin $Benches}).Count -eq 0){
        $proof=@();if($Full){$proof=@('--require-system')}
        & python -B tools/check_timing150.py @proof
        if($LASTEXITCODE){throw 'Timing-iteration evidence audit failed'}
    }
}finally{Pop-Location}
