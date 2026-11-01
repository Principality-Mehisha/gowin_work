function Get-ProjectSources {
    param([string]$ProjectRoot)
    $text = Get-Content -LiteralPath (Join-Path $ProjectRoot 'GW_PROBLEM_TOW.gprj') -Raw
    # Gowin may save a shortened XML version that .NET's parser rejects.
    $header = '<?xml version="1"'
    if ($text.StartsWith($header)) {
        $text = '<?xml version="1.0"' + $text.Substring($header.Length)
    }
    [xml]$project = $text
    @($project.Project.FileList.File | Where-Object { $_.type -eq 'file.verilog' -and $_.enable -eq '1' } | ForEach-Object {
        $path = Join-Path $ProjectRoot $_.path
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing RTL: $path" }
        $path
    })
}
