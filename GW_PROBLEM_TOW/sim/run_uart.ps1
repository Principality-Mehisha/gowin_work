$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python tools/make_uart_fixtures.py
    if ($LASTEXITCODE -ne 0) { throw 'UART fixtures failed' }
    if (-not (Test-Path sim/uart_work)) {
        & vlib sim/uart_work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    $rtlSources = (Get-ChildItem src -Filter *.v -File).FullName
    & vlog -sv +incdir+src +incdir+sim -work sim/uart_work @rtlSources sim/sd_card_model.v sim/tb_uart_protocol.sv sim/tb_uart_player.sv sim/tb_note_audition.sv sim/tb_uart_notes.sv sim/tb_tjc_status.sv
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    foreach ($bench in @('tb_tjc_status', 'tb_note_audition', 'tb_uart_protocol', 'tb_uart_player', 'tb_uart_notes')) {
        $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' +
            $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/uart_work $bench -do $commands -l "sim/${bench}.log"
        if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
    }
} finally { Pop-Location }
