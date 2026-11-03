function Get-ProjectSources {
    param([string]$ProjectRoot,[string]$GowinRoot='D:/Gowin/Gowin_V1.9.12.03_x64')
    $text = Get-Content -LiteralPath (Join-Path $ProjectRoot 'GW_PROBLEM_TOW.gprj') -Raw
    # Gowin may save a shortened XML version that .NET's parser rejects.
    $header = '<?xml version="1"'
    if ($text.StartsWith($header)) {
        $text = '<?xml version="1.0"' + $text.Substring($header.Length)
    }
    [xml]$project = $text
    $primitive=Join-Path $GowinRoot 'IDE/simlib/gw5a/prim_sim.v'
    if(-not(Test-Path -LiteralPath $primitive)){throw "Missing official simulation library: $primitive"}
    $primitive
    Join-Path $ProjectRoot 'sim/audio_gate_cdc_monitor.sv'
    @($project.Project.FileList.File | Where-Object { $_.type -eq 'file.verilog' -and $_.enable -eq '1' } | ForEach-Object {
        $path = Join-Path $ProjectRoot $_.path
        # The official IP generator supplies a plain primitive-level ModelSim model.
        if($_.path -eq 'ip/audio_fifo32/audio_fifo32.v'){$path=[IO.Path]::ChangeExtension($path,'.vo')}
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing RTL: $path" }
        $path
    })
}
