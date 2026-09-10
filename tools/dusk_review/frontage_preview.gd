extends "res://tools/dusk_review/harold_review.gd"
# Pause the validated opening for art inspection; normal wheel/pan/Home input stays active.
var held := false
func _process(delta: float) -> bool:
	if not active or comparing or elapsed<2.:
		return super._process(delta)
	if not held:
		held=true
		root.title="Dead Street - Harold frontage review (paused)"
		var view=runtime.get_node("TacticalBattleView")
		view._dusk_zoom=1.25
		view._dusk_pan=Vector2(-10,-5)
		view._frame_camera()
	return false
