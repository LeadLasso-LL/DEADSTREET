param([string]$Godot, [int]$Seed = 2005)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '../..')
if (Test-Path override.cfg) { throw 'An override.cfg already exists; preserve it and reconcile capture settings first.' }
try {
    @'
[display]
window/size/viewport_width=1920
window/size/viewport_height=1080
window/size/window_width_override=1920
window/size/window_height_override=1080
'@ | Set-Content -Encoding ASCII override.cfg
    & $Godot --path . --resolution 1920x1080 --fixed-fps 30 --disable-vsync --write-movie tools/battle_showcase/results/harold_4v4_raw.avi --script tools/battle_showcase/review.gd -- "--seed=$Seed" --recording
    if ($LASTEXITCODE -ne 0) { throw "Godot capture failed: $LASTEXITCODE" }
} finally {
    Remove-Item override.cfg -ErrorAction SilentlyContinue
}
