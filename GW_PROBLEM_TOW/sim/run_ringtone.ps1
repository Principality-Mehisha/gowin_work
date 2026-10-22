$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    if (-not (Test-Path sim/ringtone_work)) {
        & vlib sim/ringtone_work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    $rtlSources = (Get-ChildItem src -Filter *.v -File).FullName
    & vlog -sv +incdir+src -work sim/ringtone_work @rtlSources sim/sd_card_model.v sim/tb_sd_ringtone.sv sim/tb_ringtone_synth.sv
    if ($LASTEXITCODE -ne 0) { throw 'vlog failed' }
    foreach ($bench in @('tb_sd_ringtone', 'tb_ringtone_synth')) {
        $commands = 'onfinish stop; run -all; if {[examine -radix unsigned /' +
            $bench + '/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        & vsim -c -voptargs=+acc -lib sim/ringtone_work $bench -do $commands -l "sim/${bench}.log"
        if ($LASTEXITCODE -ne 0) { throw "$bench failed" }
    }
    & python tools/check_ringtone_synth.py
    if ($LASTEXITCODE -ne 0) { throw 'Ringtone audio check failed' }
} finally {
    Pop-Location
}
