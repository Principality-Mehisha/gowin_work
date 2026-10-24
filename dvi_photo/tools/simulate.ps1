param(
    [string]$IcarusBin = "",
    [string]$ModelSimBin = "F:\Quartus\modelsim_ase\win32aloem",
    [string]$PythonExe = ""
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
if (!$PythonExe) {
    $bundledPython = Join-Path $env:USERPROFILE '.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
    if (Test-Path -LiteralPath $bundledPython) { $PythonExe = $bundledPython }
    else { $PythonExe = (Get-Command python -ErrorAction Stop).Source }
}
Push-Location $root
try {
    & $PythonExe tools/generate_waterfall.py
    if ($LASTEXITCODE -ne 0) { throw "ROM/reference generation failed" }
    & $PythonExe tools/render_waterfall.py --reference
    if ($LASTEXITCODE -ne 0) { throw "Pixel reference generation failed" }
    if ($IcarusBin) {
        $sources = @('src/tmds_encoder.v','src/piano_keymap.v','src/piano_score_rom.v',
                     'src/waterfall_engine.v','src/piano_roll_bitmap.v','src/piano_scene.v','src/video_source.v')
        foreach ($test in @('tb_tmds','tb_waterfall','tb_roll_bitmap','tb_scene','tb_video')) {
            & "$IcarusBin\iverilog.exe" -g2012 -Wall -I src -s $test -o "sim/$test.out" @sources "sim/$test.v"
            if ($LASTEXITCODE -ne 0) { throw "$test compilation failed" }
            & "$IcarusBin\vvp.exe" "sim/$test.out"
            if ($LASTEXITCODE -ne 0) { throw "$test simulation failed" }
        }
    } else {
        & "$ModelSimBin\vsim.exe" -c -l sim/simulation.log -do sim/run.do
        if ($LASTEXITCODE -ne 0) { throw "ModelSim regression failed" }
    }
    & $PythonExe tools/render_waterfall.py --verify-rtl --gif
    if ($LASTEXITCODE -ne 0) { throw "RTL image verification failed" }
} finally {
    Pop-Location
}
