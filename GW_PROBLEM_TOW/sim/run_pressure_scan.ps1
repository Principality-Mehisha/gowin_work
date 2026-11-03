$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    $out='output/pressure_scan'
    New-Item -ItemType Directory -Force $out | Out-Null
    if(-not(Test-Path "$out/work")){& vlib "$out/work";if($LASTEXITCODE){throw 'vlib failed'}}
    & vlog -sv -work "$out/work" src/input/pressure/pressure_adc_scan.v sim/tb_pressure_adc_scan.sv
    if($LASTEXITCODE){throw 'ADC scan compile failed'}
    $commands='onfinish stop; run -all; if {[examine -radix unsigned /tb_pressure_adc_scan/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
    & vsim -c -voptargs=+acc -lib "$out/work" tb_pressure_adc_scan -do $commands -l "$out/tb_pressure_adc_scan.log"
    if($LASTEXITCODE){throw 'Default ADC scan failed'}
    & vsim -c -voptargs=+acc -lib "$out/work" tb_pressure_adc_scan `
        -gSLOT_CYCLES=100 -gADC_HALF_CYCLES=2 -gSAMPLE_CYCLE=90 `
        -do $commands -l "$out/tb_pressure_adc_scan_fast.log"
    if($LASTEXITCODE){throw 'Parameterized ADC scan failed'}
}finally{Pop-Location}
