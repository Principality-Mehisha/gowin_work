param([string[]]$Benches=@('tb_instrument_bank','tb_board_controls','tb_note_audition','tb_tjc_status','tb_uart_protocol','tb_uart_notes','tb_uart_player','tb_video_player','tb_sd_ringtone','tb_score_full','tb_score_player'))
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python tools/make_test_fixtures.py
    if($LASTEXITCODE){throw 'Fixture generation failed'}
    $out='output/no_clarinet'
    New-Item -ItemType Directory -Force $out | Out-Null
    if(-not(Test-Path "$out/work")){ & vlib "$out/work" }
    if($LASTEXITCODE){throw 'vlib failed'}
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/tb_instrument_bank.sv sim/tb_board_controls.sv sim/tb_note_audition.sv sim/tb_tjc_status.sv sim/tb_uart_protocol.sv sim/tb_uart_player.sv sim/tb_uart_notes.sv sim/tb_sd_ringtone.sv sim/tb_score_player.v sim/tb_score_full.v sim/tb_video_player.sv
    if($LASTEXITCODE){throw 'Compilation failed'}
    foreach($bench in $Benches) {
        $extra=@();if($bench -eq 'tb_uart_protocol'){$extra=@('-gUART_TICKS=8')}
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        if($bench -in @('tb_score_player','tb_score_full')){Push-Location sim}
        try {
            $prefix=if($bench -in @('tb_score_player','tb_score_full')){'../'}else{''}
            & vsim -c -voptargs=+acc -lib "${prefix}$out/work" $bench @extra -do $commands -l "${prefix}$out/$bench.log"
            if($LASTEXITCODE){throw "$bench failed"}
        }finally{if($bench -in @('tb_score_player','tb_score_full')){Pop-Location}}
    }
}finally{Pop-Location}
