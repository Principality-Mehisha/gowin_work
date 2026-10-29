function Get-ProjectSources {
    param([string]$ProjectRoot)
    [xml]$project = Get-Content -LiteralPath (Join-Path $ProjectRoot 'GW_PROBLEM_TOW.gprj') -Raw
    @($project.Project.FileList.File | Where-Object { $_.type -eq 'file.verilog' -and $_.enable -eq '1' } | ForEach-Object {
        $path = Join-Path $ProjectRoot $_.path
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing RTL: $path" }
        $path
    })
}
