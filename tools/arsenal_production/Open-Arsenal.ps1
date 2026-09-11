$ArsenalProject = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$ArsenalGodot = Join-Path $env:USERPROFILE 'OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe'
& $ArsenalGodot --path $ArsenalProject 'res://gameplay/arsenal_review.tscn'
