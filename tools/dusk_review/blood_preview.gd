extends SceneTree
func _initialize(): call_deferred("showcase")
func showcase():
	root.size=Vector2i(1024,340)
	root.content_scale_size=Vector2i(1024,340)
	var background=ColorRect.new()
	background.color=Color("#303938");background.size=Vector2(1024,340);root.add_child(background)
	var m=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/manifest.json"))
	var anchors=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/abdomen.json"))
	var stage=Node2D.new();root.add_child(stage)
	var specs=[["2_pistol","idle",2,"OPEN JACKET"],["2_pistol","wounded_walk",1,"WOUNDED / BLOOD ON"],["2_pistol","wounded_walk",1,"WOUNDED / BLOOD OFF"],["0_uzi_smg","wounded_walk",1,"ABDOMEN STAIN"]]
	var sprites=[]
	for i in range(4):
		var spec=specs[i]
		var sprite=Sprite2D.new();sprite.centered=false;sprite.position=Vector2(i*256,30);sprite.scale=Vector2(2,2)
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		var atlas=AtlasTexture.new();atlas.atlas=load("res://assets/art/units/pixel_v1/"+spec[0]+".png");sprite.texture=atlas
		var mat=ShaderMaterial.new();mat.shader=load("res://assets/art/street_detail/unit_finish.gdshader")
		mat.set_shader_parameter("clothing_mask",load("res://assets/art/units/pixel_v1/blood_masks/"+spec[0]+".png"));mat.set_shader_parameter("blood_enabled",i!=2);mat.set_shader_parameter("wounded_stain",i>0);sprite.material=mat;stage.add_child(sprite);sprites.append(sprite)
		var label=Label.new();label.text=spec[3];label.position=Vector2(i*256+6,12);label.add_theme_font_size_override("font_size",13);stage.add_child(label)
	for frame in range(24):
		for i in range(4):
			var spec=specs[i];var f=int(m.clips[spec[1]].start)+(frame if i>0 else 0)
			sprites[i].texture.region=Rect2(f%32*128,(int(spec[2])*6+f/32)*128,128,128)
			if i>0:
				var a=anchors[spec[0]+"/"+m.directions[spec[2]]+"/"+spec[1]+"/"+str(frame)]
				sprites[i].material.set_shader_parameter("stain_center",Vector2(a[0],a[1]))
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://tools/dusk_review/results/blood_preview_%02d.png"%frame)
	print("BLOOD_SHADER_PREVIEW_OK");quit()
