from pathlib import Path
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
src=(R/'tools/sandbox_glossaries_20260914/validate.gd').read_text(encoding='utf-8')
src=src.replace('tools/sandbox_glossaries_20260914/','tools/sandbox_finish_20260915/')
src=src.replace('Input.parse_input_event(e)','root.push_input(e,true)')
src=src.replace('const Vehicles=preload', 'const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")\nconst Vehicles=preload')
src=src.replace('\tawait item(arsenal,"desert_eagle");', '\tawait item(arsenal,"glock_17");await shot("arsenal_glock");await class_tab(arsenal,"smg");await item(arsenal,"uzi");await shot("arsenal_uzi");await class_tab(arsenal,"pistol")\n\tawait item(arsenal,"desert_eagle");')
src=src.replace('\t\tcheck(factions.unit_images.size()==5,"five classes "+id)', '''
		check(factions.unit_images.size()==5,"five classes "+id)
		var has_photo=not str(factions.selected_faction_rows.get("leader_photo","")).is_empty()
		check((factions.leader_image!=null)==has_photo,"leader photo binding "+id)
		if has_photo:
			check(factions.leader_image.texture!=null,"leader texture loaded "+id)
			check(factions.leader_image.texture.get_size()==Vector2(288,359),"complete photo dimensions "+id)
			check(not factions.leader_image.get_rect().intersects(factions.detail_labels.title.get_rect()),"photo clears title "+id)
			check(not factions.leader_image.get_rect().intersects(factions.detail_labels.leader.get_rect()),"photo clears leader name "+id)
		if id in ["ventresca","whittaker","wm_corp","nbpd"]:await shot("faction_"+id)
''')
src=src.replace('\t\t\tcheck(Weapons.get_model(picture.get_meta("weapon")).weapon_type_id==role,', '\t\t\tcheck(picture.texture.get_size()==Vector2(90,80),"uniform portrait canvas "+id+" "+role)\n\t\t\tcheck(Weapons.get_model(picture.get_meta("weapon")).weapon_type_id==role,')
src=src.replace('\t\t\tcheck(arsenal.detail_labels.size()>=17,"complete weapon spec fields "+id)', '''
			check(arsenal.detail_labels.size()>=18,"complete weapon spec fields "+id)
			check(Weapons.purchase_price(id)>0,"valid game price "+id)
			check(arsenal.detail_labels.Price.text=="$"+arsenal.money(Weapons.purchase_price(id)),"display uses canonical price "+id)
''')
src=src.replace('\t\tvehicles.choose_class(kind);await frames(3)', '''
		vehicles.choose_class(kind);await frames(3)
		var last_price=-1
		for vehicle_id in vehicles.visible_models:
			var next_price=int(Vehicles.model(vehicle_id).price)
			check(next_price>=last_price,"ascending vehicle price "+kind+" "+vehicle_id)
			last_price=next_price
''')
needle='\t# Existing fleet selection and Encounter Lab remain reachable from the new shell.'
extra='''
	check(Weapons.purchase_price("invalid-model")==-1,"unknown weapon has no free purchase quote")
	var inventory=JSON.parse_string(FileAccess.get_file_as_string("res://tools/portrait_audit_20260914/build_validation.json"))
	for row in inventory.rows:
		var path="res://"+str(row.portrait)
		var texture=Anim._load_texture(path)
		check(texture!=null,"all-loadout portrait loads "+row.variant)
		if texture!=null:
			var shown=texture.get_image()
			var original=Image.load_from_file(path)
			if shown.is_compressed():shown.decompress()
			shown.convert(Image.FORMAT_RGBA8);original.convert(Image.FORMAT_RGBA8)
			check(shown.get_size()==Vector2i(90,80),"all-loadout fixed frame "+row.variant)
			check(shown.get_data()==original.get_data(),"no stale imported portrait "+row.variant)
'''
assert needle in src;src=src.replace(needle,extra+needle)
src=src.replace('"paired_unit_images":115,','"paired_unit_images":115,"all_portrait_loadouts":691,"leader_photos":20,')
src=src.replace('shown.convert(Image.FORMAT_RGBA8);original.convert(Image.FORMAT_RGBA8)', 'shown.convert(Image.FORMAT_RGBA8);original.convert(Image.FORMAT_RGBA8)\n\t\t\toriginal.fix_alpha_edges()')
src=src.replace('Vector2i(390,844)', 'Vector2i(1440,1000)')
(O/'check_native.gd').write_text(src,encoding='utf-8')
print('CHECKS_READY')
