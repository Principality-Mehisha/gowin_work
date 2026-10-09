param([string]$IcarusBin = "D:\Icarus_Verilog\iverilog\bin")
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Push-Location $root
try {
    & "$IcarusBin\iverilog.exe" -g2012 -Wall -s tb_tmds -o sim/tmds.out src/tmds_encoder.v sim/tb_tmds.v
    if ($LASTEXITCODE -ne 0) { throw "TMDS compilation failed" }
    & "$IcarusBin\vvp.exe" sim/tmds.out
    if ($LASTEXITCODE -ne 0) { throw "TMDS simulation failed" }
    & "$IcarusBin\iverilog.exe" -g2012 -Wall -DPHOTO_ROM_SIM -s tb_video -o sim/video.out src/video_source.v src/photo_rom.v sim/tb_video.v
    if ($LASTEXITCODE -ne 0) { throw "Video compilation failed" }
    & "$IcarusBin\vvp.exe" sim/video.out
    if ($LASTEXITCODE -ne 0) { throw "Video simulation failed" }
} finally {
    Pop-Location
}
