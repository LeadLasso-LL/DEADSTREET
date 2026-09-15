class_name BattleForceCommandCatalog
extends RefCounted

# Whole-force in-battle tactical commands. Flee/withdraw is not a force command.
const COMMAND_PUSH := "push"
const COMMAND_HOLD := "hold"
const COMMAND_FOCUS_LEFT := "focus_left"
const COMMAND_FOCUS_RIGHT := "focus_right"
const COMMAND_FALL_BACK := "fall_back"

const DEFAULT_COMMAND := COMMAND_HOLD


static func command_ids() -> Array[String]:
	var ids: Array[String] = [
		COMMAND_PUSH,
		COMMAND_HOLD,
		COMMAND_FOCUS_LEFT,
		COMMAND_FOCUS_RIGHT,
		COMMAND_FALL_BACK,
	]
	return ids


static func is_valid_command(command_id: String) -> bool:
	match command_id:
		COMMAND_PUSH, COMMAND_HOLD, COMMAND_FOCUS_LEFT, COMMAND_FOCUS_RIGHT, COMMAND_FALL_BACK:
			return true
		_:
			return false
