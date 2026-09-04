class_name TacticalDynamicBattlefieldLayer
extends Node2D

# Per-frame tactical presentation: participants, shots, overlay, deployment feedback.

var host: TacticalBattleView = null
var draw_count: int = 0


func _draw() -> void:
	draw_count += 1
	if host == null:
		return
	host.paint_dynamic_battlefield(self)
