$ErrorActionPreference = "Stop"
$simDir = $PSScriptRoot

Push-Location $simDir
try {
    & vsim -c -do "do run_score.do" -l score_suite.log
    if ($LASTEXITCODE -ne 0) { throw "Score-stream regression failed" }
} finally {
    Pop-Location
}
