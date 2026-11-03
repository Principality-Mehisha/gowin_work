param([string]$GowinRoot='D:/Gowin/Gowin_V1.9.12.03_x64')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    $out='output/audio150/ip_work'
    if(-not(Test-Path $out)){& vlib $out;if($LASTEXITCODE){throw 'vlib failed'}}
    & vlog -work $out "$GowinRoot/IDE/simlib/gw5a/prim_sim.v"
    if($LASTEXITCODE){throw 'Official primitive models failed'}
    & vlog -sv -work $out ip/audio_fifo32/audio_fifo32.vo ip/audio_pll150/audio_pll150_mod.v ip/audio_pll150/audio_pll150.v src/video/pll_init.v src/audio/audio_clock150.v src/audio/audio_cdc_fifo.v sim/tb_audio150_ip.sv
    if($LASTEXITCODE){throw 'Audio IP simulation compile failed'}
    & vsim -c -voptargs=+acc -lib $out tb_audio150_ip -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_audio150_ip/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l output/audio150/tb_audio150_ip.log
    if($LASTEXITCODE){throw 'Audio IP simulation failed'}
}finally{Pop-Location}
