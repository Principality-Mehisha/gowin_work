param([string]$GowinIde='D:/Gowin/Gowin_V1.9.12.03_x64/IDE')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python tools/extract_ddr_native_mc.py
    if($LASTEXITCODE){throw 'Native MC extraction failed'}
    if(-not(Test-Path sim/ddr_native_work)){ & vlib sim/ddr_native_work }
    if($LASTEXITCODE){throw 'vlib failed'}
    & vlog -sv -work sim/ddr_native_work (Join-Path $GowinIde 'simlib/gw5a/prim_sim.v') output/ddr_migration/native_mc_probe.v src/ddr/ddr_asset_seed.v src/ddr/ddr_asset_service.v sim/tb_ddr_native_write.sv
    if($LASTEXITCODE){throw 'Native MC compilation failed'}
    & vsim -c -voptargs=+acc -lib sim/ddr_native_work tb_ddr_native_write -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_ddr_native_write/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l output/ddr_migration/tb_ddr_native_write.log
    if($LASTEXITCODE){throw 'Native MC bootstrap write regression failed'}
} finally {Pop-Location}
