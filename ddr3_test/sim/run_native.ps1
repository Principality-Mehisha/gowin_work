param(
    [string]$PythonExe='python',
    [string]$GowinIde='D:/Gowin/Gowin_V1.9.12.03_x64/IDE',
    [switch]$Baseline
)
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
    & $PythonExe ../tools/extract_native_mc.py
    if($LASTEXITCODE){throw 'MC extraction failed'}
    if(!(Test-Path native_work)) { & vlib native_work; if($LASTEXITCODE){throw 'vlib failed'} }
    $bist=if($Baseline){'evidence/ddr3_bist_v2.v'}else{'../src/ddr3_bist.v'}
    & vlog -sv -work native_work (Join-Path $GowinIde 'simlib/gw5a/prim_sim.v') native_generated/native_mc_probe.v $bist tb_native_mc.sv
    if($LASTEXITCODE){throw 'Native MC compilation failed'}
    $log=if($Baseline){'native_v2_reproduction.log'}else{'tb_native_mc.log'}
    & vsim -c -voptargs=+acc -lib native_work tb_native_mc -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_native_mc/simulation_passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l $log
    if($LASTEXITCODE){throw "Native MC test failed (baseline V2 is expected to fail). See $log"}
} finally { Pop-Location }
