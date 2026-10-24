$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '../sim')
try {
    if (!(Test-Path -LiteralPath 'work')) {
        & vlib work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    & vlog -sv ../src/ws2812_tx.v ../src/ws2812_16.v tb_ws2812_tx.sv tb_ws2812_16.sv
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    & vsim -c -do run.do
    if ($LASTEXITCODE -ne 0) { throw 'Simulation failed' }
} finally {
    Pop-Location
}
