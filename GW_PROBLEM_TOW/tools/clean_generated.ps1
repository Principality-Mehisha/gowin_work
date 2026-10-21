$ErrorActionPreference = "Stop"
$root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$relativeTargets = @(
    "work",
    "sim/work",
    "sim/work_score",
    "sim/bass_work",
    "sim/tone_work",
    "tools/__pycache__",
    "tools/vendor/mido/__pycache__",
    "tools/vendor/mido/backends/__pycache__",
    "tools/vendor/mido/messages/__pycache__",
    "tools/vendor/mido/midifiles/__pycache__",
    "tools/vendor/mido/scripts/__pycache__",
    "tools/vendor/packaging/__pycache__",
    "tools/vendor/packaging/licenses/__pycache__"
)

foreach ($relativeTarget in $relativeTargets) {
    $target = Join-Path $root $relativeTarget
    if (-not (Test-Path -LiteralPath $target)) { continue }

    $resolvedTarget = (Resolve-Path -LiteralPath $target).Path
    if (-not $resolvedTarget.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean a path outside the project: $resolvedTarget"
    }

    Remove-Item -LiteralPath $resolvedTarget -Recurse -Force
    Write-Output "Removed generated cache: $relativeTarget"
}

foreach ($relativeTarget in @("transcript", "vsim.wlf", "sim/transcript")) {
    $target = Join-Path $root $relativeTarget
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        Remove-Item -LiteralPath $target -Force
        Write-Output "Removed simulator scratch file: $relativeTarget"
    }
}

Get-ChildItem (Join-Path $root "sim") -File |
    Where-Object { $_.Name -like "*.vvp" -or $_.Name -like "*_pcm.txt" } |
    ForEach-Object {
        Remove-Item -LiteralPath $_.FullName -Force
        Write-Output "Removed simulator scratch file: sim/$($_.Name)"
    }
