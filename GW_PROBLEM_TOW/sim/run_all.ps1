$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python tools/check_project.py
    if ($LASTEXITCODE -ne 0) { throw 'Project check failed' }
    foreach ($suite in @('run.ps1','run_uart.ps1','run_score.ps1','run_ringtone.ps1')) {
        & (Join-Path $PSScriptRoot $suite)
    }
    Write-Output 'PASS: all active regression suites'
} finally { Pop-Location }
