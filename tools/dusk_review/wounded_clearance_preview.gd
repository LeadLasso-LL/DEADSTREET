extends SceneTree
func _initialize(): call_deferred("showcase")
func showcase():
	root.size=Vector2i(1536,768)
	root.content_scale_size=root.size
	var bg=ColorRect.new()
	bg.color=Color("#303938");bg.size=Vector2(root.size);root.add_child(bg)
	var m=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/manifest.json"))
	var anchors=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/abdomen.json"))
	var sprites=[]
	var variants=["0_uzi_smg","1_ak_rifle","2_pistol","1_pump_shotgun"]
	for row in range(4):
		for d in range(8):
			var v=variants[row]
			var sprite=Sprite2D.new();sprite.centered=false;sprite.position=Vector2(d*192,row*192+8);sprite.scale=Vector2(1.5,1.5)
			sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			var atlas=AtlasTexture.new();atlas.atlas=load("res://assets/art/units/pixel_v1/"+v+".png");sprite.texture=atlas
			var mat=ShaderMaterial.new();mat.shader=load("res://assets/art/street_detail/unit_finish.gdshader")
			mat.set_shader_parameter("clothing_mask",load("res://assets/art/units/pixel_v1/blood_masks/"+v+".png"));mat.set_shader_parameter("wounded_stain",true);sprite.material=mat
			root.add_child(sprite);sprites.append(sprite)
			var label=Label.new();label.text=v+" / "+m.directions[d];label.position=Vector2(d*192+5,row*192+4);label.add_theme_font_size_override("font_size",12);root.add_child(label)
	for frame in range(24):
		for row in range(4):
			for d in range(8):
				var sprite=sprites[row*8+d]
				var f=int(m.clips.wounded_walk.start)+frame
				sprite.texture.region=Rect2(f%32*128,(d*6+f/32)*128,128,128)
				var a=anchors[variants[row]+"/"+m.directions[d]+"/wounded_walk/"+str(frame)]
				sprite.material.set_shader_parameter("stain_center",Vector2(a[0],a[1]))
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tools/dusk_review/results/clearance_%02d.png"%frame)
	print("WOUNDED_CLEARANCE_PREVIEW_OK");quit()
