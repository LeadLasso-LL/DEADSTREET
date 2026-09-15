class_name TacticalStaticBattlefieldLayer
extends Node2D

# Retained static battlefield presentation. Redraws only when the host requests it.

var host: TacticalBattleView = null
var draw_count: int = 0


func _draw() -> void:
	draw_count += 1
	if host == null:
		return
	host.paint_static_battlefield(self)
