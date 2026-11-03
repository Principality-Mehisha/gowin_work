param([string[]]$Benches=@('tb_piano88_core','tb_piano88_uart','tb_note_audition','tb_uart_protocol','tb_uart_notes'))
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    $out='output/piano88'
    New-Item -ItemType Directory -Force $out | Out-Null
    if(-not(Test-Path "$out/work")){& vlib "$out/work";if($LASTEXITCODE){throw 'vlib failed'}}
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/tb_piano88_core.sv `
        sim/tb_piano88_uart.sv sim/tb_note_audition.sv sim/tb_uart_protocol.sv sim/tb_uart_notes.sv
    if($LASTEXITCODE){throw 'Piano88 simulation compile failed'}
    foreach($bench in $Benches){
        $extra=@();if($bench -eq 'tb_uart_protocol'){$extra=@('-gUART_TICKS=8')}
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench @extra -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    if('tb_piano88_core' -in $Benches){
        & vsim -c -voptargs=+acc -lib "$out/work" tb_piano88_core -gLIVE_DYNAMICS=0 `
            -do 'onfinish stop; run -all; if {[examine -radix unsigned /tb_piano88_core/passed] != 1} {quit -code 1 -f}; quit -code 0 -f' `
            -l "$out/tb_piano88_core_fixed.log"
        if($LASTEXITCODE){throw 'Fixed-gain piano88 core failed'}
    }
    if(@('tb_piano88_core','tb_piano88_uart','tb_note_audition','tb_uart_protocol','tb_uart_notes' |
        Where-Object {$_ -notin $Benches}).Count -eq 0){
        & python -B tools/check_piano88.py
        if($LASTEXITCODE){throw 'Piano88 evidence/command check failed'}
    }
}finally{Pop-Location}
