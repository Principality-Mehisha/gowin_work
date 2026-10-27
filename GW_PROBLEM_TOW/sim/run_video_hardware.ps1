param([string]$GowinRoot='D:/Gowin/Gowin_V1.9.12.03_x64')
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    New-Item -ItemType Directory -Force output/video_integration | Out-Null
    if(-not(Test-Path sim/video_hardware_work)){
        & vlib sim/video_hardware_work
        if($LASTEXITCODE -ne 0){throw 'vlib failed'}
    }
    & vlog -work sim/video_hardware_work "$GowinRoot/IDE/simlib/gw5a/prim_sim.v"
    if($LASTEXITCODE -ne 0){throw 'Gowin model compile failed'}
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv -work sim/video_hardware_work @sources sim/tb_video_hardware.sv
    if($LASTEXITCODE -ne 0){throw 'Video hardware compile failed'}
    & vsim -c -voptargs=+acc -lib sim/video_hardware_work tb_video_hardware -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_video_hardware/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' -l output/video_integration/tb_video_hardware.log
    if($LASTEXITCODE -ne 0){throw 'Video startup/reset test failed'}
} finally {Pop-Location}
