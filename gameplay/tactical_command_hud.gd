extends Control
# Full, stable roster. All commands are selection-scoped; battle state owns orders.
const Query = preload("res://gameplay/tactical_unit_hud_query.gd")
const Card = preload("res://gameplay/tactical_unit_card.gd")
const Compact = preload("res://gameplay/tactical_compact_card.gd")
const Icon = preload("res://gameplay/tactical_weapon_icon.gd")
const Factions = preload("res://gameplay/battle_faction_identity.gd")
const PlaybackSymbol = preload("res://gameplay/tactical_playback_symbol.gd")
const LOS = preload("res://battle/combat/battle_line_of_sight_service.gd")
const ROLES = ["pistol", "smg", "rifle", "shotgun", "sniper"]
var view: Node
var surface: Control
var background: Panel
var font: SystemFont
var cards: Dictionary = {}
var buttons: Dictionary = {}
var class_buttons: Dictionary = {}
var playback_buttons: Array[Button] = []
var playback: Control
var command_row: Control
var count_label: RichTextLabel
var faction_label: Label
var faction_emblem: TextureRect
var strength_label: Label
var strength_fill: ColorRect
var feedback_label: Label
var normal = Card.style(Color("#242d30"), Color("#4b5757"))
var active = Card.style(Color("#42473b"), Color("#c9bf93"))
var roster: Array[String] = []
var battle_id: int = 0
var height: float = 216.0
var feedback_clock: float = 0.0

func setup(p_view: Node) -> void:
	view = p_view
	var order_audio = preload("res://gameplay/tactical_order_audio.gd").new()
	order_audio.view = view
	add_child(order_audio)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	font.font_weight = 600
	surface = Control.new()
	add_child(surface)
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	background = Panel.new()
	surface.add_child(background)
	background.position = Vector2(12, 0)
	background.add_theme_stylebox_override("panel", Card.style(Color("#11191d"), Color("#495454")))
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label = RichTextLabel.new()
	surface.add_child(count_label)
	count_label.position = Vector2(24, 8)
	count_label.size = Vector2(400, 22)
	count_label.bbcode_enabled = true
	count_label.scroll_active = false
	count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	count_label.add_theme_font_override("normal_font", font)
	count_label.add_theme_font_size_override("normal_font_size", 12)
	count_label.add_theme_color_override("default_color", Color("#c5c9bc"))
	faction_emblem = TextureRect.new()
	surface.add_child(faction_emblem)
	faction_emblem.position = Vector2(671, 21)
	faction_emblem.size = Vector2(38, 38)
	faction_emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	faction_emblem.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	faction_emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Factions.style_emblem(faction_emblem)
	# Two aligned fields fill the space after the class selectors.
	faction_label = label(surface, Vector2(719, 12), Vector2(174, 52), "", 13)
	faction_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	faction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var divider = ColorRect.new()
	surface.add_child(divider)
	divider.position = Vector2(906, 12)
	divider.size = Vector2(1, 50)
	divider.color = Color(1, 1, 1, .5)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strength_label = label(surface, Vector2(923, 12), Vector2(203, 32), "RELATIVE STRENGTH", 11)
	strength_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	strength_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var strength_bg = ColorRect.new()
	surface.add_child(strength_bg)
	strength_bg.position = Vector2(923, 49)
	strength_bg.size = Vector2(203, 7)
	strength_bg.color = Color("#86545b")
	strength_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	strength_fill = ColorRect.new()
	strength_bg.add_child(strength_fill)
	strength_fill.size = Vector2(101.5, 7)
	strength_fill.color = Color("#83a38a")
	strength_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var all = button(surface, "SELECT ALL", Vector2(24, 37), Vector2(118, 27))
	all.tooltip_text = "Select all living units · Ctrl+A · Shift adds to selection"
	all.pressed.connect(func(): if controller() != null: controller().select_class())
	class_buttons[""] = all
	for i in range(ROLES.size()):
		var role: String = ROLES[i]
		var b = button(surface, role.to_upper(), Vector2(150 + i * 102, 37), Vector2(95, 27))
		b.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		var icon = Icon.new()
		b.add_child(icon)
		icon.weapon_type = role
		icon.position = Vector2(5, 4)
		icon.size = Vector2(24, 20)
		b.tooltip_text = "Select all " + role + " units · Shift adds to selection"
		b.pressed.connect(func(): if controller() != null: controller().select_class(role, Input.is_key_pressed(KEY_SHIFT)))
		class_buttons[role] = b
	command_row = Control.new()
	surface.add_child(command_row)
	command_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var x = 24.0
	for row in [["hold", "HOLD", 82], ["push", "PUSH", 82], ["fall_back", "FALL BACK", 102], ["clear", "CLEAR ORDERS", 126]]:
		var b = button(command_row, row[1], Vector2(x, 0), Vector2(row[2], 29))
		var id: String = row[0]
		b.pressed.connect(func(): if controller() != null: controller().command_selected(id))
		b.tooltip_text = {"hold":"Find nearby protective cover and hold", "push":"Set an advance line; resume role behavior after advancing", "fall_back":"Set a retreat line; take cover on the friendly side and hold", "clear":"Clear selected units' movement and target orders; resume automatic behavior"}[id]
		buttons[id] = b
		x += row[2] + 6
	playback = Control.new()
	surface.add_child(playback)
	playback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var emblem = CheckButton.new()
	playback.add_child(emblem)
	emblem.position = Vector2(222, 0)
	emblem.size = Vector2(111, 29)
	emblem.text = "EMBLEMS"
	emblem.button_pressed = true
	emblem.focus_mode = Control.FOCUS_NONE
	emblem.add_theme_font_size_override("font_size", 9)
	emblem.toggled.connect(func(value): view.battle_presentation.identifiers_enabled = value)
	for i in range(4):
		var b = button(playback, "", Vector2(i * 54, 0), Vector2(50, 29))
		var symbol = PlaybackSymbol.new()
		symbol.mode = i
		b.add_child(symbol)
		symbol.size = b.size
		b.tooltip_text = ["Pause · Space toggles pause / resume", "Slow motion · 0.5×", "Normal speed · 1×", "Fast forward · 1.5×"][i]
		b.pressed.connect(set_playback.bind(i))
		playback_buttons.append(b)
	var sound = CheckButton.new()
	playback.add_child(sound)
	sound.position = Vector2(336, 0)
	sound.size = Vector2(85, 29)
	sound.text = "AUDIO"
	sound.button_pressed = true
	sound.focus_mode = Control.FOCUS_NONE
	sound.add_theme_font_size_override("font_size", 9)
	sound.toggled.connect(func(value): view.battle_presentation.audio_enabled = value)
	feedback_label = label(surface, Vector2(24, 194), Vector2(1100, 17), "", 10)
	feedback_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS

func controller():
	return view.orders_controller if view != null else null

func label(parent, at: Vector2, dimensions: Vector2, text: String, points: int) -> Label:
	return Card.label(parent, at, dimensions, text, points, Color("#c5c9bc"), font)

func button(parent, text: String, at: Vector2, dimensions: Vector2) -> Button:
	var b = Button.new()
	parent.add_child(b)
	b.position = at
	b.size = dimensions
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_override("font", font)
	b.add_theme_font_size_override("font_size", 10)
	for state in ["normal", "disabled"]:
		b.add_theme_stylebox_override(state, normal)
	for state in ["hover", "pressed"]:
		b.add_theme_stylebox_override(state, active)
	return b

func set_playback(index: int) -> void:
	var b = view._battle_state()
	if b == null or b.battle_phase != "active":
		return
	if index == 0:
		b.tactical_paused = true
	else:
		b.set_tactical_speed([0.0, 0.5, 1.0, 1.5][index])

func select_card(id: String) -> void:
	if controller() != null:
		controller().select_participant(id, Input.is_key_pressed(KEY_SHIFT))

func _process(delta: float) -> void:
	if view == null or not is_instance_valid(view):
		return
	var b = view._battle_state()
	visible = view.visible and view._is_dusk_street() and b != null and b.battle_phase in ["active", "resolved"]
	if visible and view.battle_presentation != null:
		visible = not view.battle_presentation.results_visible()
	if not visible:
		return
	var c = controller()
	if c != null:
		c.sync_from_authority()
	if battle_id != b.get_instance_id():
		battle_id = b.get_instance_id()
		for widget in cards.values():
			widget.queue_free()
		cards.clear()
		roster.clear()
		var units = Query.friendly_cards(b, "")
		units.sort_custom(func(a,z): return a.participant_id < z.participant_id if a.weapon_type == z.weapon_type else ROLES.find(a.weapon_type) < ROLES.find(z.weapon_type))
		for unit in units:
			roster.append(unit.participant_id)
			var widget = Compact.new()
			surface.add_child(widget)
			widget.setup(font)
			widget.pressed.connect(select_card.bind(unit.participant_id))
			cards[unit.participant_id] = widget
	var ordered: Array[String] = Query.living_first_ids(b, roster)
	var columns = mini(12, maxi(1, ordered.size()))
	var rows = ceili(float(ordered.size()) / columns)
	height = 130.0 + rows * 96.0
	var factor = get_viewport_rect().size.x / 1152.0
	surface.scale = Vector2.ONE * factor
	surface.position = Vector2(0, get_viewport_rect().size.y - height * factor)
	surface.size = Vector2(1152, height)
	background.size = Vector2(1128, height - 5)
	command_row.position = Vector2(0, height - 57)
	playback.position = Vector2(710, height - 57)
	feedback_label.position.y = height - 22
	var width = (1104.0 - (columns - 1) * 5.0) / columns
	var living = 0
	for i in range(ordered.size()):
		var id = ordered[i]
		var p = b.get_participant(id)
		var widget = cards[id]
		widget.position = Vector2(24 + (i % columns) * (width + 5), 71 + (i / columns) * 96)
		widget.size = Vector2(width, 94)
		widget.refresh(p, c != null and c.is_selected(id), roster.find(id) + 1)
		if p.is_alive:
			living += 1
	count_label.text = "[color=#8cb994]%d[/color] ACTIVE · [color=#d87572]%d[/color] ELIMINATED" % [living, roster.size() - living]
	var faction = Factions.for_side(b, Query.player_side_id(b))
	faction_label.text = faction.name
	faction_emblem.texture = faction.emblem
	if not b.strength_snapshot.is_empty():
		var share = float(b.strength_snapshot.shares.get(Query.player_side_id(b), .5))
		strength_fill.size.x = 203 * share
		strength_label.text = "RELATIVE STRENGTH / " + ("ADVANTAGE" if share > .55 else ("DISADVANTAGE" if share < .45 else "EVEN"))
	var selected = 0 if c == null else c.selected_participant_ids.size()
	for id in buttons:
		buttons[id].disabled = selected == 0 or b.battle_phase != "active"
		buttons[id].add_theme_stylebox_override("normal", active if c != null and c.pending_command_id == id else normal)
	for role in class_buttons:
		var eligible = 0
		for id in roster:
			var p = b.get_participant(id)
			if p.is_alive and (role.is_empty() or p.weapon_type == role):
				eligible += 1
		class_buttons[role].disabled = eligible == 0 or b.battle_phase != "active"
	for i in range(4):
		playback_buttons[i].disabled = b.battle_phase != "active"
		var pressed = b.tactical_paused if i == 0 else (not b.tactical_paused and b.tactical_speed == [0.0, .5, 1.0, 1.5][i])
		playback_buttons[i].add_theme_stylebox_override("normal", active if pressed else normal)
	feedback_clock -= delta
	if feedback_clock <= 0.0:
		feedback_clock = .15
		feedback_label.text = ""
		# Only operational problems belong here; control instructions live in the manual.
		if c != null:
			if c.feedback.begins_with("Order unavailable"):
				feedback_label.text = c.feedback
			for problem in ["No route to destination", "Cover occupied or no reachable protective slot", "Target is no longer available"]:
				if problem in c.feedback:
					feedback_label.text = problem
		if c != null and selected == 1 and c.pending_command_id.is_empty():
			var detail = unit_feedback(b, b.get_participant(c.selected_participant_id))
			if not detail.is_empty():
				feedback_label.text = detail
	queue_redraw()

func unit_feedback(b, p) -> String:
	if p == null:
		return ""
	if p.player_order_feedback.begins_with("Waiting"):
		return p.player_order_feedback
	if p.is_wounded:
		return "WOUNDED · survival behavior active"
	if not p.player_priority_target_id.is_empty():
		var target = b.get_participant(p.player_priority_target_id)
		if target != null and target.is_alive:
			var weapon = Card.Weapons.for_participant(p)
			if weapon != null and p.battle_position.distance_to(target.battle_position) > weapon.max_range:
				return "PRIORITY TARGET · out of range; position retained"
			var sight = LOS.check_participant_to_participant(b, p.participant_id, target.participant_id)
			if sight == null or not sight.success or not sight.has_line_of_sight:
				return "PRIORITY TARGET · shot blocked; position retained"
	return ""

func _draw() -> void:
	var c = controller()
	if c != null and c.dragging and c.drag_start.distance_to(c.drag_end) > 8.0:
		var rect = Rect2(c.drag_start, c.drag_end - c.drag_start).abs()
		draw_rect(rect, Color(.8, .8, .6, .08))
		draw_rect(rect, Color("#d3cb9d"), false, 1.5)
