class_name BattleCombatPressureSnapshot
extends RefCounted

# Battle-local explainable pressure for one living positioned participant.
# Not persisted to campaign Soldier / SoldierGroup / TravelingForce.

var participant_id: String = ""
var total_pressure: float = 0.0
var nearby_dead_allies: int = 0
var nearby_wounded_allies: int = 0
var nearby_living_allies: int = 0
var nearby_hostiles: int = 0
var casualty_pressure: float = 0.0
var wounded_pressure: float = 0.0
var hostile_pressure: float = 0.0
var isolation_pressure: float = 0.0
var multi_direction_pressure: float = 0.0
var friendly_support: float = 0.0
