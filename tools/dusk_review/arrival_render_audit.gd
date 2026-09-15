extends "res://tools/dusk_review/harold_review.gd"
func _process(_delta: float) -> bool:
	if not active:return false
	var view=runtime.get_node("TacticalBattleView")
	print("ARRIVAL_BINDINGS ",runtime.get_current_session().battle_state.battlefield_geometry.visual_bindings.size())
	for id in view.actor_presenter._sprites:
		var node=view.actor_presenter._sprites[id]
		print("LEGACY_VEHICLE ",id," texture=",node.texture.resource_path," pos=",node.position," scale=",node.scale," mod=",node.modulate," visible=",node.is_visible_in_tree())
	for node in view._dusk_nodes:
		if not node.prop.is_empty() and node.prop[2]=="car":
			print("PARKED ",node.prop[0]," bounds=",node.prop[1]," position=",node.position," paint=",node.material.get_shader_parameter("paint")," mod=",node.modulate," self=",node.self_modulate)
	for id in view._dusk_vehicle_nodes:
		var node=view._dusk_vehicle_nodes[id]
		print("ARRIVAL ",id," bounds=",node.prop[1]," position=",node.position," paint=",node.material.get_shader_parameter("paint")," mod=",node.modulate," self=",node.self_modulate," texture=",node.textures["burgundy_sedan"].resource_path)
	quit()
	return false
