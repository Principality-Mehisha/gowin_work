$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
    if(!(Test-Path work)) { & vlib work; if($LASTEXITCODE){throw 'vlib failed'} }
    & vlog -sv -work work ../src/ddr3_bist.v ../src/ddr3_status.v tb_ddr3_bist.sv tb_ddr3_status.sv
    if($LASTEXITCODE){throw 'vlog failed'}
    foreach($bench in @('tb_ddr3_bist','tb_ddr3_status')) {
        & vsim -c -voptargs=+acc -lib work $bench -do "onfinish stop; onerror {quit -code 1 -f}; run -all; if {[examine -radix unsigned /$bench/simulation_passed] != 1} {quit -code 1 -f}; quit -code 0 -f" -l "$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
} finally { Pop-Location }
