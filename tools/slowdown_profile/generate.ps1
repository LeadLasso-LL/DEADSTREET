param([string]$BaselineRef = "")
$root='C:\Users\brand\OneDrive\Documents\dead-street'
Set-Location $root
$dest='tools/slowdown_profile'
foreach($pair in @(@('battle/runtime/battle_runtime_service.gd','runtime'),@('battle/combat/battle_combat_behavior_service.gd','combat'),@('battle/combat/battle_combat_cover_evaluation_service.gd','cover_eval'),@('battle/combat/battle_line_of_sight_service.gd','los'))) {
 $s=[IO.File]::ReadAllText((Join-Path $root $pair[0])) -replace 'class_name \w+\r?\n',''
 if($BaselineRef) { $s=((git show ($BaselineRef+':'+$pair[0])) -join [char]10) -replace 'class_name \w+\r?\n','' }
 $s=$s.Replace('res://battle/combat/battle_combat_behavior_service.gd','res://tools/slowdown_profile/combat.gd')
 $matches=[regex]::Matches($s,'(?ms)^static func (\w+)\((.*?)\)\s*->\s*([^:\r\n]+):')
 $wrappers=''
 foreach($m in $matches) {
  $name=$m.Groups[1].Value; $params=$m.Groups[2].Value; $ret=$m.Groups[3].Value.Trim()
  $args=([regex]::Matches($params,'(?:^|,)\s*(\w+)\s*:') | ForEach-Object {$_.Groups[1].Value}) -join ', '
  $s=$s.Replace($m.Value,$m.Value.Replace("func $name(","func _raw_$name("))
  $wrappers+="`n`nstatic func $name($params) -> ${ret}:`n`tvar t := Time.get_ticks_usec()`n"
  if($ret -eq "void") {$wrappers+="`t_raw_$name($args)`n"} else {$wrappers+="`tvar result = _raw_$name($args)`n"}
  $wrappers+="`tProbe.record('$($pair[1]).$name', Time.get_ticks_usec()-t)`n"
  if($ret -ne "void") {$wrappers+="`treturn result`n"}
 }
 $s=$s.Replace("extends RefCounted","extends RefCounted`nconst Probe = preload('res://tools/slowdown_profile/probe.gd')")
 [IO.File]::WriteAllText((Join-Path $root "$dest/$($pair[1]).gd"),$s+$wrappers)
}
foreach($name in @('combat','cover_eval')) {
 $p=Join-Path $root ('tools/slowdown_profile/'+$name+'.gd')
 $s=[IO.File]::ReadAllText($p).Replace('res://battle/combat/battle_combat_cover_evaluation_service.gd','res://tools/slowdown_profile/cover_eval.gd').Replace('res://battle/combat/battle_line_of_sight_service.gd','res://tools/slowdown_profile/los.gd')
 [IO.File]::WriteAllText($p,$s)
}
