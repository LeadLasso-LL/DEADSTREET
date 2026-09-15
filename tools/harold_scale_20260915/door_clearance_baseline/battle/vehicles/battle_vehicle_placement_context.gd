class_name BattleVehiclePlacementContext
extends RefCounted

# Optional richer parking context for later authored geography.
# Empty/default means the current deployment-region fallback heuristic.
# Not campaign-map coordinates and not a required v1 input.

var has_anchor: bool = false
var anchor_position: Vector2 = Vector2.ZERO
var has_arrival_heading: bool = false
var arrival_heading: Vector2 = Vector2.ZERO


func _init(
	p_has_anchor: bool = false,
	p_anchor_position: Vector2 = Vector2.ZERO,
	p_has_arrival_heading: bool = false,
	p_arrival_heading: Vector2 = Vector2.ZERO
) -> void:
	has_anchor = p_has_anchor
	anchor_position = p_anchor_position
	has_arrival_heading = p_has_arrival_heading
	arrival_heading = p_arrival_heading
