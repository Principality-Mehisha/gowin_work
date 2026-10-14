$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sampleDir = Join-Path $projectRoot 'assets\piano'
New-Item -ItemType Directory -Force -Path $sampleDir | Out-Null
$repository = 'https://raw.githubusercontent.com/nbrosowsky/tonejs-instruments/master'
$sampleNames = @('C1','Fs1','C2','Fs2','C3','Fs3','C4','Fs4','C5','Fs5','C6','Fs6','C7','Fs7','C8')
foreach ($sampleName in $sampleNames) {
    $target = Join-Path $sampleDir ($sampleName + '.wav')
    if (-not (Test-Path -LiteralPath $target)) {
        Invoke-WebRequest -Uri "$repository/samples/piano/$sampleName.wav" -OutFile $target
    }
    Write-Output "piano sample: $sampleName.wav"
}
Invoke-WebRequest -Uri "$repository/LICENSE.md" -OutFile (Join-Path $sampleDir 'LICENSE.md')
Invoke-WebRequest -Uri "$repository/sample-source-info.txt" -OutFile (Join-Path $sampleDir 'sample-source-info.txt')
