function Get-ProjectSources {
    param([string]$ProjectRoot)
    [xml]$project = Get-Content -LiteralPath (Join-Path $ProjectRoot 'GW_PROBLEM_TOW.gprj') -Raw
    # Gowin-only encrypted DDR PHY/mDRP sources are hardware build inputs.
    # Behavioral suites bind ddr_asset_service to the native-interface model.
    @($project.Project.FileList.File | Where-Object { $_.type -eq 'file.verilog' -and $_.enable -eq '1' -and $_.path -notin @('src/ddr/ip/memory/ddr3_memory_interface.v','src/ddr/pll_mDRP_intf.v') } | ForEach-Object {
        $path = Join-Path $ProjectRoot $_.path
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing RTL: $path" }
        $path
    })
}
