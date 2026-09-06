class_name TacticalIdentitySnapshot
extends RefCounted

# Frozen presentation identity for one battle participant.
# Combat, movement, cover, and hit-testing must not read these fields.
# Person naming is deferred; HUD currently uses weapon/role labels.

var gang_archetype_id: String = ""
var appearance_variant_id: String = ""
var appearance_seed: int = 0
var firearm_visual_id: String = ""


func is_valid() -> bool:
	return not gang_archetype_id.is_empty() and not appearance_variant_id.is_empty()
