extends Button
const Card = preload("res://gameplay/tactical_unit_card.gd")
const Query = preload("res://gameplay/tactical_unit_hud_query.gd")
const Icon = preload("res://gameplay/tactical_weapon_icon.gd")
var participant_id: String = ""
var portrait: TextureRect
var weapon_symbol: Control
var role: Label
var status: Label
var health: ColorRect
var number: Label
var normal = Card.style(Color("#20282b"), Color("#485152"))
var chosen = Card.style(Color("#383d35"), Color("#d5c995"))
var eliminated = Card.style(Color("#1b2022"), Color("#343b3d"))
var badge: String = ""
var command_status: Label

func setup(font: Font) -> void:
	focus_mode = Control.FOCUS_NONE
	size = Vector2(88, 84)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", chosen)
	add_theme_stylebox_override("pressed", chosen)
	add_theme_stylebox_override("disabled", eliminated)
	weapon_symbol = Icon.new()
	add_child(weapon_symbol)
	weapon_symbol.position = Vector2(6, 5)
	weapon_symbol.size = Vector2(34, 32)
	portrait = TextureRect.new()
	add_child(portrait)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role = Card.label(self, Vector2(6, 49), Vector2(76, 14), "", 10, Color("#dfdfd2"), font)
	status = Card.label(self, Vector2(6, 37), Vector2(30, 11), "", 8, Color("#a5ada8"), font)
	command_status = Card.label(self, Vector2(6, 64), Vector2(76, 12), "", 9, Color("#a8adb1"), font)
	command_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	number = Card.label(self, Vector2(27, 38), Vector2(52, 10), "", 8, Color("#909b94"), font)
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	health = ColorRect.new()
	add_child(health)
	health.position = Vector2(6, 78)
	health.mouse_filter = Control.MOUSE_FILTER_IGNORE

func refresh(p, selected: bool, ordinal: int) -> void:
	var c = Query.card_for(p, p.participant_id if selected else "")
	participant_id = p.participant_id
	disabled = not p.is_alive
	add_theme_stylebox_override("normal", chosen if selected else normal)
	weapon_symbol.weapon_type = p.weapon_type
	weapon_symbol.modulate.a = 1.0 if p.is_alive else .35
	portrait.position = Vector2(size.x - 41, 3)
	portrait.size = Vector2(35, 43)
	portrait.modulate = Color.WHITE if p.is_alive else Color(.4, .4, .4)
	if p.identity != null:
		var variant = Card.Anim.variant_for(p.identity.gang_archetype_id, p.weapon_type, p.weapon_model_id, p.specialist_id)
		if not Card.textures.has(variant):
			Card.textures[variant] = Card.Anim._load_texture(Card.Anim.atlas_path(variant, "portraits"))
		portrait.texture = Card.textures[variant]
	role.text = p.weapon_type.to_upper()
	role.size.x = size.x - 12
	status.text = "ELIMINATED" if not p.is_alive else ("WOUNDED" if p.is_wounded else "%d%%" % c.vitality_percent)
	status.position.y = 64 if p.is_wounded or not p.is_alive else 37
	status.size.x = size.x - 12 if p.is_wounded or not p.is_alive else 30
	status.add_theme_color_override("font_color", Color("#d4a966") if p.is_wounded and p.is_alive else Color("#a5ada8"))
	number.position.x = size.x - 51
	number.size.x = 45
	number.text = "T%d · %02d" % [p.unit_tier, ordinal]
	health.size = Vector2((size.x - 12) * c.vitality_ratio, 3)
	health.color = Color("#c9a367") if p.is_wounded else Color("#84a78a")
	var model = Card.Weapons.for_participant(p)
	tooltip_text = role.text + " · Unit tier %d\n" % p.unit_tier
	if model != null:
		tooltip_text += model.display_name + " · Weapon tier %d\n" % model.tier
	tooltip_text += Card.Armor.label(p.armor_id) + "\n" + p.player_order_feedback
	if p.is_wounded and p.is_alive:
		tooltip_text += "\nWounded: survival behavior controls movement"
	badge = p.current_player_group_command()
	command_status.size.x = size.x - 12
	command_status.text = {"hold":"Holding", "push":"Pushing", "fall_back":"Falling Back"}.get(badge, "")
	command_status.add_theme_color_override("font_color", {"hold":Color("#a8adb1"), "push":Color("#8eb798"), "fall_back":Color("#cc8987")}.get(badge, Color.WHITE))
