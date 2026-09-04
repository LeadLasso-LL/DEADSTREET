class_name AuthoredBattlefieldDefinition
extends RefCounted

# Reusable authored battlefield payload. Runtime geometry is still
# BattlefieldGeometry after apply. This is not campaign-map localization.

const BattleObstacle := preload("res://battle/geometry/battle_obstacle.gd")
const BattleCoverObject := preload("res://battle/geometry/battle_cover_object.gd")
const BattleCoverSlot := preload("res://battle/geometry/battle_cover_slot.gd")
const BattleSurfaceRegion := preload("res://battle/geometry/battle_surface_region.gd")
const BattlePresentationMarking := preload("res://battle/geometry/battle_presentation_marking.gd")
const BattleDeploymentArea := preload("res://battle/geometry/battle_deployment_area.gd")
const BattleVehiclePlacementContext := preload("res://battle/vehicles/battle_vehicle_placement_context.gd")

var definition_id: String = ""
var width: float = 0.0
var height: float = 0.0
var surfaces: Array[BattleSurfaceRegion] = []
var presentation_markings: Array[BattlePresentationMarking] = []
var obstacles: Array[BattleObstacle] = []
var cover_objects: Array[BattleCoverObject] = []
var cover_slots: Array[BattleCoverSlot] = []
var attacker_deployment_area: BattleDeploymentArea = BattleDeploymentArea.new()
var defender_deployment_area: BattleDeploymentArea = BattleDeploymentArea.new()
var attacker_vehicle_placement_context: BattleVehiclePlacementContext = null
var defender_vehicle_placement_context: BattleVehiclePlacementContext = null


func is_valid() -> bool:
	if definition_id.is_empty():
		return false
	if not is_finite(width) or not is_finite(height):
		return false
	if width <= 0.0 or height <= 0.0:
		return false
	if attacker_deployment_area == null or not attacker_deployment_area.is_valid():
		return false
	if defender_deployment_area == null or not defender_deployment_area.is_valid():
		return false
	if not attacker_deployment_area.has_pockets() or not defender_deployment_area.has_pockets():
		return false
	return true
