$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python tools/check_project.py
    if ($LASTEXITCODE -ne 0) { throw 'Project check failed' }
    foreach ($suite in @('run.ps1','run_upload.ps1','run_analysis.ps1','run_pressure.ps1','run_marimba_pressure.ps1','run_effects.ps1')) {
        & (Join-Path $PSScriptRoot $suite)
        if ($LASTEXITCODE -ne 0) { throw "$suite failed" }
    }
    & (Join-Path $PSScriptRoot 'run_structure.ps1') -Benches tb_instrument_bank,tb_note_audition,tb_tjc_status
    if ($LASTEXITCODE -ne 0) { throw 'Control and synth-equivalence regressions failed' }
    Write-Output 'PASS: all active regression suites'
} finally { Pop-Location }
