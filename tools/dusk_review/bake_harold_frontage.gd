extends SceneTree
# Render retained map art once at 3x authoring resolution. Runtime lights stay separate.
const Art=preload("res://gameplay/harold_street_art.gd")
const Catalog=preload("res://battle/geometry/harold_street_catalog.gd")
const OUTPUT="res://assets/art/harold_frontage/"
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var jobs=[["ground",[],Rect2(-320,-280,1152,568)]]
	for row in Catalog.props():
		if row[2]=="building" and not str(row[0]).begins_with("south"):
			var b: Rect2=row[1]
			jobs.append([row[0],row,Rect2(b.position.x*8-2,b.end.y*6-264,b.size.x*8+4,270)])
	for job in jobs:
		var bounds: Rect2=job[2]
		var viewport=SubViewport.new()
		viewport.size=Vector2i(bounds.size*3)
		viewport.transparent_bg=true
		viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		viewport.world_2d=World2D.new()
		root.add_child(viewport)
		var stage=Node2D.new()
		stage.position=-bounds.position*3
		stage.scale=Vector2.ONE*3
		viewport.add_child(stage)
		var art=Art.new()
		art.bake_source=true
		art.prop=job[1]
		if not art.prop.is_empty():
			var b: Rect2=art.prop[1]
			art.position=Vector2(b.get_center().x*8,b.end.y*6)
		stage.add_child(art)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var error=viewport.get_texture().get_image().save_png(OUTPUT+str(job[0])+".png")
		if error!=OK:
			push_error("FRONTAGE_BAKE_FAILED "+str(job[0]))
			quit(1)
			return
		print("FRONTAGE_BAKED ",job[0]," ",viewport.size)
		viewport.queue_free()
		await process_frame
	quit()
