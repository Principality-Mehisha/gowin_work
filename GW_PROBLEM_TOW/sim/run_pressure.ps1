param([string[]]$Benches=@('tb_pressure_curve','tb_pressure_events','tb_pressure','tb_pitch_groups','tb_pressure_integration','tb_play_admission','tb_instrument_bank'))
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    . tools/project_sources.ps1
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    & python -B tools/make_upload_fixtures.py
    if($LASTEXITCODE){throw 'Slot fixtures failed'}
    $out='output/pressure_keyboard'
    New-Item -ItemType Directory -Force $out | Out-Null
    if(-not(Test-Path "$out/work")) { & vlib "$out/work"; if($LASTEXITCODE){throw 'vlib failed'} }
    $sources=Get-ProjectSources $projectRoot
    & vlog -sv +incdir+sim -work "$out/work" @sources sim/sd_card_model.v sim/pressure_synth_adapter.sv sim/tb_pressure_curve.sv sim/tb_pressure_events.sv sim/tb_pressure.sv sim/tb_pitch_groups.sv sim/tb_pressure_integration.sv sim/tb_instrument_bank.sv sim/tb_synth.sv sim/tb_play_admission.sv
    if($LASTEXITCODE){throw 'Pressure simulation compilation failed'}
    foreach($bench in $Benches) {
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    $commands='onfinish stop; run -all; if {[examine -radix unsigned /tb_synth/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
    & vsim -c -voptargs=+acc -lib "$out/work" tb_synth -gLIVE_DYNAMICS=1 -do $commands -l "$out/tb_synth_live.log"
    if($LASTEXITCODE){throw '88-voice live-gain deadline regression failed'}
    if($Benches.Count -eq 7) {
        & python -B tools/check_pressure.py
        if($LASTEXITCODE){throw 'Pressure evidence collection failed'}
    }
} finally { Pop-Location }
