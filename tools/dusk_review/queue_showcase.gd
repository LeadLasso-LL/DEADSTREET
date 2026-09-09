extends "res://tools/dusk_review/decision_review.gd"
var flash_captured := false
func _process(delta:float)->bool:
	var result=super._process(delta)
	if active and not comparing and not flash_captured:
		var b=runtime.get_current_session().battle_state
		for e in b.combat_feedback_events:
			if b.elapsed_time_seconds-e.elapsed_time_seconds<.035 and elapsed>2.5:
				flash_captured=true
				capture_flash()
				break
	return result
func capture_flash():
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tools/dusk_review/results/queue_flash.png")
