class_name TacticalUnitPipelineSpec
extends RefCounted

# Offline character-production contract for Dead Street.
# Runtime does not import Blender or 3D characters.
# Output of this spec feeds TacticalUnitAnimationCatalog.
#
# Camera / scale / lighting numbers below are PROVISIONAL_NOT_CANON.
# They are last-used technical placeholders, not a product-accepted camera.
# The next accepted character source must recalibrate them.

const WORLD_HUMAN_HEIGHT_UNITS := 1.8
const VIEW_PIXELS_PER_UNIT := 8.0

# PROVISIONAL_NOT_CANON — art canvas convention, not locked product scale.
const ART_PIXELS_PER_UNIT := 50.0
const CANVAS_PX := 256
const FIGURE_FIT_PX := 200
const FOOT_PAD_PX := 16
const FOOT_OFFSET_Y := 0.0

# PROVISIONAL_NOT_CANON — do not inherit as the Dead Street character camera.
const CAMERA_KIND := "orthographic"
const CAMERA_ELEVATION_DEG := 48.0
const CAMERA_PITCH_DEG := 48.0
const CAMERA_FOV_ORTHO_SCALE := 2.05
const LIGHT_YAW_DEG := -32.0
const LIGHT_PITCH_DEG := 52.0
const FACING_YAW_OFFSET_DEG := 0.0

const DIRECTION_YAW_DEG := {
	"s": 0.0,
	"se": 45.0,
	"e": 90.0,
	"ne": 135.0,
	"n": 180.0,
	"nw": 225.0,
	"w": 270.0,
	"sw": 315.0
}

const CLIP_IDLE := "idle"
const CLIP_WALK := "walk"
const CLIP_AIM := "aim"
const CLIP_FIRE := "fire"
const CLIP_RELOAD := "reload"
const CLIP_COVER_EXPOSED_IDLE := "cover_exposed_idle"
const CLIP_COVER_TUCKED_IDLE := "cover_tucked_idle"
const CLIP_COVER_POPOUT := "cover_popout"
const CLIP_COVER_FIRE := "cover_fire"
const CLIP_WOUNDED_IDLE := "wounded_idle"
const CLIP_WOUNDED_WALK := "wounded_walk"
const CLIP_HIT := "hit"
const CLIP_DEATH := "death"

const OUTPUT_ROOT := "res://assets/tactical/units"


static func clip_folder(archetype_id: String, variant_id: String, clip_id: String, direction_id: String) -> String:
	return "%s/%s/%s/%s/%s" % [OUTPUT_ROOT, archetype_id, variant_id, clip_id, direction_id]


static func frame_path(
	archetype_id: String,
	variant_id: String,
	clip_id: String,
	direction_id: String,
	frame_index: int
) -> String:
	return "%s/%02d.png" % [
		clip_folder(archetype_id, variant_id, clip_id, direction_id),
		frame_index
	]
