class_name BattleCombatRandom
extends RefCounted

# Numerical Recipes LCG. Simulation/replay only. Not cryptographic.
const MULTIPLIER := 1664525
const INCREMENT := 1013904223
const MODULUS := 4294967296

var seed_value: int = 1
var state: int = 1


func _init(p_seed: int = 1) -> void:
	seed_value = p_seed
	state = _normalize_state(p_seed)


func snapshot_state() -> int:
	return state


func restore_state(p_state: int) -> void:
	state = _normalize_state(p_state)


func next_normalized() -> float:
	state = (state * MULTIPLIER + INCREMENT) % MODULUS
	state = _normalize_state(state)
	return float(state) / float(MODULUS)


static func seed_from_string(value: String) -> int:
	var hash_value: int = 2166136261
	var index: int = 0
	while index < value.length():
		hash_value = int((hash_value ^ value.unicode_at(index)) * 16777619)
		index += 1
	var seed_value: int = hash_value % MODULUS
	if seed_value < 0:
		seed_value += MODULUS
	if seed_value == 0:
		return 1
	return seed_value


static func _normalize_state(value: int) -> int:
	var normalized: int = value % MODULUS
	if normalized < 0:
		normalized += MODULUS
	if normalized == 0:
		return 1
	return normalized
