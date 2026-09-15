from pathlib import Path
R=Path(__file__).parents[2]
p=R/'assets/art/street_detail/unit_finish.gdshader';s=p.read_text()
s=s.replace('uniform float outline_width = 2.5;','uniform float outline_width = 3.0;\nuniform bool blood_enabled = true;\nuniform bool wounded_stain = false;\nuniform vec2 stain_center = vec2(64.0,64.0);')
s=s.replace('vec3 toned=c.rgb*vec3',"""vec2 local_pixel=mod(floor(uv/TEXTURE_PIXEL_SIZE),128.0);
 vec2 stain_delta=local_pixel-stain_center;
 float stain=max(step(length(stain_delta/vec2(4.2,3.3)),1.0),step(length((stain_delta-vec2(1.0,3.0))/vec2(2.1,2.5)),1.0));
 float fabric=1.0-step(0.16,max(max(c.r,c.g),c.b)-min(min(c.r,c.g),c.b));
 if(blood_enabled && wounded_stain && c.a>.5 && stain>.5 && fabric>.5) c.rgb=mix(vec3(.28,.06,.08),vec3(.49,.10,.12),step(0.0,stain_delta.x));
 vec3 toned=c.rgb*vec3""")
p.write_text(s)
p=R/'gameplay/tactical_actor_presenter.gd';s=p.read_text()
s=s.replace('var _muzzles: Dictionary = {}','var _muzzles: Dictionary = {}\nvar _abdomen: Dictionary = {}\nvar blood_enabled := true\nvar blood_layer: Node2D\n')
s=s.replace('\t_claimed.clear()\n\t_claimed_participants.clear()\n\tif root == null',"""\tif unit_root != null and blood_layer == null:
		blood_layer=load("res://gameplay/tactical_blood_layer.gd").new()
		blood_layer.name="BloodPresentation"
		blood_layer.z_index=1
		unit_root.get_parent().add_child(blood_layer)
	if blood_layer != null:
		blood_layer.enabled=blood_enabled
		blood_layer.sync(battle_state)
	_claimed.clear()
	_claimed_participants.clear()
	if root == null""",1)
needle='\t_motion[id] = state'
insert="""	if body.material is ShaderMaterial:
		body.material.set_shader_parameter("blood_enabled",blood_enabled)
		body.material.set_shader_parameter("wounded_stain",participant.is_wounded and participant.is_alive and clip.begins_with("wounded"))
		if participant.is_wounded and clip.begins_with("wounded"):
			if _abdomen.is_empty(): _abdomen=JSON.parse_string(FileAccess.get_file_as_string("res://assets/art/units/pixel_v1/abdomen.json"))
			var stain_variant: String=TacticalUnitAnimationCatalog.variant_for(participant.identity.gang_archetype_id,participant.weapon_type)
			var point: Array=_abdomen.get(stain_variant+"/"+dir_id+"/"+clip+"/"+str(body.frame),[64.0,64.0])
			body.material.set_shader_parameter("stain_center",Vector2(float(point[0]),float(point[1])))
"""
assert needle in s;s=s.replace(needle,insert+needle);p.write_text(s)
print('Blood presentation and unified switch wired')
