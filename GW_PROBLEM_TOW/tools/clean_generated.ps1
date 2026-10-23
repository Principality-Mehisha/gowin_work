$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$targets = @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'sim') | Where-Object {
    ($_.PSIsContainer -and ($_.Name -in @('work','work_score','marimba_wav') -or $_.Name -like '*_work')) -or
    (-not $_.PSIsContainer -and ($_.Extension -in @('.log','.wlf','.vvp','.wav','.json') -or $_.Name -like '*_pcm.txt' -or $_.Name -eq 'transcript'))
})
$targets += @(Get-ChildItem -LiteralPath (Join-Path $projectRoot 'output') -ErrorAction SilentlyContinue | Where-Object Name -in @('score_test','ringtone_test','uart_test'))
foreach ($item in $targets) {
    $resolved = (Resolve-Path -LiteralPath $item.FullName).Path
    if (-not $resolved.StartsWith($projectRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw "Outside project: $resolved" }
    Remove-Item -LiteralPath $resolved -Recurse -Force
}
# Preserve bitstreams, optional installed dependencies and SD backups.
