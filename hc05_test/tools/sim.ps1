$ErrorActionPreference = 'Stop'
Push-Location (Join-Path $PSScriptRoot '../sim')
try {
    if (!(Test-Path -LiteralPath 'work')) {
        & vlib work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    & vlog -sv ../src/board_reset.v ../src/byte_fifo.v ../src/uart_rx.v ../src/uart_tx.v ../src/hc05_commands.v ../src/hc05_test.v tb_hc05_commands.sv tb_hc05_test.sv tb_hc05_nominal.sv
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    & vsim -c -do run.do
    if ($LASTEXITCODE -ne 0) { throw 'Simulation failed' }
} finally {
    Pop-Location
}
