param([string[]]$Benches=@('tb_sine_pair_rom','tb_rom_sharing','tb_marimba','tb_instrument_bank'))
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    & python -B tools/check_project.py
    if($LASTEXITCODE){throw 'Project check failed'}
    $out='output/rom_sharing'
    $before="$out/before"
    if(-not(Test-Path -LiteralPath "$before/instrument_voice_bank_before.v")){
        throw 'Missing frozen pre-change references; do not regenerate from the modified RTL'
    }
    if(-not(Test-Path -LiteralPath "$out/work")){& vlib "$out/work";if($LASTEXITCODE){throw 'vlib failed'}}
    $sources=@('src/audio/adsr_pipeline.v','src/audio/output_limiter.v',
        'src/audio/marimba_body_filter.v','src/audio/sine_pair_rom.v',
        'src/audio/piano_synth.v','src/audio/marimba_synth.v','src/audio/instrument_voice_bank.v')
    & vlog -sv -work "$out/work" @sources "$before/piano_synth_before.v" `
        "$before/marimba_synth_before.v" "$before/instrument_voice_bank_before.v" `
        sim/tb_rom_sharing.sv sim/tb_marimba.sv sim/tb_instrument_bank.sv
    if($LASTEXITCODE){throw 'ROM sharing simulation compile failed'}
    foreach($bench in $Benches){
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /'+$bench+'/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib "$out/work" $bench -do $commands -l "$out/$bench.log"
        if($LASTEXITCODE){throw "$bench failed"}
    }
    if(@('tb_sine_pair_rom','tb_rom_sharing','tb_marimba','tb_instrument_bank' |
        Where-Object {$_ -notin $Benches}).Count -eq 0){
        & python -B tools/check_rom_sharing.py
        if($LASTEXITCODE){throw 'ROM sharing evidence audit failed'}
    }
}finally{Pop-Location}
