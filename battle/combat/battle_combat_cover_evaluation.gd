class_name BattleCombatCoverEvaluation
extends RefCounted

# Query-only threat-relative cover assessment. Not occupancy and not mitigation.

var slot_id: String = ""
var legal: bool = false
var reachable: bool = false
var protection_factor: float = 0.0
var alignment_dot: float = 0.0
var has_useful_direction: bool = false
var has_line_of_sight: bool = false
var blocking_obstacle_id: String = ""
var in_weapon_max_range: bool = false
var move_distance: float = INF
var combat_usable: bool = false
var in_band: bool = true
var band_error: float = 0.0
