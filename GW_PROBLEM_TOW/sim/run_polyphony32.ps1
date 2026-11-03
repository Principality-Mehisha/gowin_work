param([string[]]$Benches=@('tb_score32_reader','tb_sd_polyphony32','tb_follow_sequencer','tb_score_full','tb_bluetooth_polyphony32'))
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    foreach($test in @('sim/test_polyphony32.py','sim/test_classical_scores.py','sim/test_bluetooth_upload.py')) {
        & python -B $test
        if($LASTEXITCODE){throw "$test failed"}
    }
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python -B tools/make_polyphony32_fixtures.py
    if($LASTEXITCODE){throw '32-slot fixtures failed'}
    & python -B tools/make_upload_fixtures.py
    if($LASTEXITCODE){throw 'Legacy fixtures failed'}
    $out='output/polyphony32'
    if(-not(Test-Path "$out/work")) {
        & vlib "$out/work"
        if($LASTEXITCODE){throw 'vlib failed'}
    }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/tb_score32_reader.sv sim/tb_sd_polyphony32.sv sim/tb_follow_sequencer.sv sim/tb_score_full.v sim/tb_bluetooth_upload.sv
    if($LASTEXITCODE){throw '32-slot compilation failed'}
    foreach($bench in $Benches) {
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    if(@('tb_score32_reader','tb_sd_polyphony32','tb_follow_sequencer','tb_score_full','tb_bluetooth_polyphony32' |
        Where-Object {$_ -notin $Benches}).Count -eq 0) {
        & python -B tools/check_polyphony32.py
        if($LASTEXITCODE){throw '32-slot evidence collection failed'}
    }
} finally { Pop-Location }
