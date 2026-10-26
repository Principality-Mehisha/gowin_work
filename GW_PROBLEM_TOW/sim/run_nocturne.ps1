param([switch]$RenderAudio)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    & python tools/check_project.py
    if($LASTEXITCODE -ne 0){throw 'Project check failed'}
    & python tools/make_nocturne_fixtures.py
    if($LASTEXITCODE -ne 0){throw 'Nocturne fixtures failed'}
    New-Item -ItemType Directory -Force output/clarinet_calibration | Out-Null
    if(-not(Test-Path sim/nocturne_work)){
        & vlib sim/nocturne_work
        if($LASTEXITCODE -ne 0){throw 'vlib failed'}
    }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work sim/nocturne_work @sources sim/sd_card_model.v sim/tb_nocturne_sd.sv sim/tb_nocturne_full.sv sim/tb_nocturne_synth.sv sim/tb_uart_protocol.sv
    if($LASTEXITCODE -ne 0){throw 'vlog failed'}
    $benches=@('tb_nocturne_full','tb_nocturne_sd','tb_uart_protocol')
    if($RenderAudio){$benches+='tb_nocturne_synth'}
    foreach($bench in $benches){
        [string[]]$extra=@()
        if($bench -eq 'tb_uart_protocol'){$extra=@('-gUART_TICKS=8')}
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/nocturne_work $bench @extra -do $commands -l "output/nocturne/$bench.log"
        if($LASTEXITCODE -ne 0){throw "$bench failed"}
    }
    if($RenderAudio){
        & python tools/check_nocturne_audio.py
        if($LASTEXITCODE -ne 0){throw 'Nocturne audio comparison failed'}
    }
}finally{Pop-Location}
