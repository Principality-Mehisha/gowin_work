$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $projectRoot 'tools/project_sources.ps1')
Push-Location $projectRoot
try {
    & python -B tools/make_upload_fixtures.py
    if ($LASTEXITCODE -ne 0) { throw 'Upload fixture generation failed' }
    & python -B tools/make_test_fixtures.py
    if ($LASTEXITCODE -ne 0) { throw 'Playback fixture generation failed' }
    & python -B sim/test_bluetooth_upload.py
    if ($LASTEXITCODE -ne 0) { throw 'Host protocol tests failed' }
    if (-not (Test-Path sim/upload_work)) {
        & vlib sim/upload_work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    $sources = Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work sim/upload_work @sources sim/sd_card_model.v sim/tb_bluetooth_upload.sv sim/tb_fixed_slot_reader.sv sim/tb_score_file_name.sv sim/tb_uart_protocol.sv sim/tb_board_controls.sv sim/tb_uart_player.sv sim/tb_uart_notes.sv sim/tb_score_player.v sim/tb_score_full.v
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    foreach ($bench in @('tb_score_file_name', 'tb_bluetooth_upload', 'tb_bluetooth_overflow', 'tb_bluetooth_reset', 'tb_fixed_slot_reader', 'tb_uart_protocol', 'tb_board_controls', 'tb_uart_player', 'tb_uart_notes', 'tb_score_player', 'tb_score_full')) {
        $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' +
            $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        $extra = @()
        if ($bench -eq 'tb_uart_protocol') { $extra = @('-gUART_TICKS=8') }
        $scoreBench = $bench -in @('tb_score_player','tb_score_full')
        if ($scoreBench) { Push-Location sim }
        try {
            $prefix = if ($scoreBench) { '../' } else { '' }
            & vsim -c -voptargs=+acc -lib "${prefix}sim/upload_work" $bench @extra -do $commands -l "${prefix}output/fixed_slots/${bench}.log"
            if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
        } finally { if ($scoreBench) { Pop-Location } }
    }
    & python -B tools/check_upload.py
    if ($LASTEXITCODE -ne 0) { throw 'Upload evidence collection failed' }
    Copy-Item -LiteralPath output/fixed_slots/verification.json -Destination output/fixed_slots/source_frozen.json
} finally { Pop-Location }
