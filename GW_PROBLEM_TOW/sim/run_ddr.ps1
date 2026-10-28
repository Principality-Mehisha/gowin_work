$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python tools/generate_ddr_assets.py --check
    if($LASTEXITCODE){throw 'DDR assets differ'}
    & python tools/make_nocturne_fixtures.py
    if($LASTEXITCODE){throw 'Nocturne fixtures failed'}
    New-Item -ItemType Directory -Force output/ddr_migration | Out-Null
    if(-not(Test-Path sim/ddr_work)){ & vlib sim/ddr_work }
    if($LASTEXITCODE){throw 'vlib failed'}
    . tools/project_sources.ps1
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work sim/ddr_work @sources sim/ddr_native_model.sv sim/tb_ddr_assets.sv sim/tb_ddr_clarinet.sv sim/sd_card_model.v sim/tb_nocturne_sd.sv sim/tb_ddr_player.sv
    if($LASTEXITCODE){throw 'DDR compilation failed'}
    foreach($bench in @('tb_ddr_assets','tb_ddr_clarinet','tb_ddr_player')){
        & vsim -c -voptargs=+acc -lib sim/ddr_work $bench -do "onfinish stop; onerror {quit -code 1 -f}; run -all; if {[examine -radix unsigned /$bench/passed] != 1} {quit -code 1 -f}; quit -code 0 -f" -l "output/ddr_migration/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
} finally {Pop-Location}
