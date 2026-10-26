param([switch]$Prepared,[switch]$Resume)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    if(-not $Prepared){
        & python tools/prepare_clarinet_segments.py
        if($LASTEXITCODE -ne 0){throw 'Segment checkpoint preparation failed'}
    }
    $manifest=Get-Content output/clarinet_calibration/segments/manifest.json -Raw | ConvertFrom-Json
    foreach($property in $manifest.inputs.PSObject.Properties){
        if((Get-FileHash -LiteralPath $property.Name -Algorithm SHA256).Hash.ToLowerInvariant() -ne $property.Value){
            throw "Checkpoint input changed: $($property.Name); run again without -Prepared"
        }
    }
    if(-not(Test-Path sim/clarinet_segment_work)){
        & vlib sim/clarinet_segment_work
        if($LASTEXITCODE -ne 0){throw 'vlib failed'}
    }
    & vlog -sv -work sim/clarinet_segment_work src/audio/clarinet_synth.v src/audio/output_limiter.v sim/tb_nocturne_synth.sv
    if($LASTEXITCODE -ne 0){throw 'vlog failed'}
    $simulator=(Get-Command vsim).Source
    $processes=@()
    foreach($number in 0..3){
        $log="output/clarinet_calibration/segments/segment$number.log"
        $part="output/clarinet_calibration/segments/segment${number}_pcm.txt"
        $meta="output/clarinet_calibration/segments/segment$number.meta"
        if($Resume -and (Test-Path $log) -and (Test-Path $part) -and
           (Get-Item $log).LastWriteTime -ge (Get-Item $meta).LastWriteTime -and
           (Select-String -LiteralPath $log -SimpleMatch '# PASS: full real-time clarinet Nocturne' -Quiet)){
            Write-Output "Reusing completed RTL segment $number"
            continue
        }
        $commands='onfinish stop; run -all; if {[examine -radix unsigned /tb_nocturne_synth/passed] != 1} {quit -code 1 -f}; quit -code 0 -f'
        $arguments=@('-c','-lib','sim/clarinet_segment_work','tb_nocturne_synth',"-gSEGMENT=$number",'-do',('"'+$commands+'"'),
            '-l',"output/clarinet_calibration/segments/segment$number.log",'-wlf',"output/clarinet_calibration/segments/segment$number.wlf")
        $processes+=Start-Process -FilePath $simulator -ArgumentList $arguments -WorkingDirectory $projectRoot -WindowStyle Hidden -PassThru `
            -RedirectStandardOutput "output/clarinet_calibration/segments/segment$number.stdout.log" `
            -RedirectStandardError "output/clarinet_calibration/segments/segment$number.stderr.log"
    }
    foreach($process in $processes){
        $process.WaitForExit()
        if($process.ExitCode -ne 0){throw "RTL segment process $($process.Id) failed; see segments/*.log"}
    }
    & python tools/join_clarinet_segments.py
    if($LASTEXITCODE -ne 0){throw 'Segment boundary/concatenation check failed'}
    & python tools/check_nocturne_audio.py
    if($LASTEXITCODE -ne 0){throw 'Full independent PCM check failed'}
    & python tools/make_clarinet_ab.py
    if($LASTEXITCODE -ne 0){throw 'Approved listening prototype check failed'}
} finally {Pop-Location}
