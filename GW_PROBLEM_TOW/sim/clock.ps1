param([string]$GowinRoot="D:/Gowin/Gowin_V1.9.12.03_x64")
$ErrorActionPreference="Stop"
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
    if(-not (Test-Path sim/clock_work)) { & vlib sim/clock_work }
    & vlog -work sim/clock_work "$GowinRoot/IDE/simlib/gw5a/prim_sim.v"
    if($LASTEXITCODE -ne 0) { throw "Gowin simulation library compilation failed" }
    & vlog -sv -work sim/clock_work src/pll_init.v src/audio_clock.v sim/tb_clock.sv
    if($LASTEXITCODE -ne 0) { throw "Clock compilation failed" }
    & vsim -c -voptargs=+acc -lib sim/clock_work tb_clock -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_clock/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l sim/tb_clock.log
    if($LASTEXITCODE -ne 0) { throw "Clock simulation failed" }
} finally { Pop-Location }
