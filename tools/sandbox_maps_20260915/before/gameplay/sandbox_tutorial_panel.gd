extends CanvasLayer
## A frozen native battle image with gameplay help. Opening it creates no battle.
const DATA_PATH = "res://assets/tutorial/harold/harold.json"
const IMAGE_PATH = "res://assets/tutorial/harold/harold.png"
const INK = Color("#eee4c7")
const TAN = Color("#dec993")
var surface: Control
var canvas: BattleImage
var tip: PanelContainer
var tip_title: Label
var tip_text: Label
var close_button: Button
var reset_button: Button
var show_button: CheckButton
var subtitle: Label
var regions: Array = []
var active_index = -1
var pointer = Vector2.ZERO
var sticky = false
var zoom = 1.0
var pan = Vector2.ZERO
var image_size = Vector2(1440,1000)
var texture: Texture2D
var font: SystemFont
var last_size = Vector2.ZERO
var previous_focus: WeakRef

func _ready() -> void:
	layer = 100
	var focused = get_viewport().gui_get_focus_owner()
	if focused != null: previous_focus = weakref(focused)
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Arial"])
	surface = Control.new()
	add_child(surface)
	surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surface.mouse_filter = Control.MOUSE_FILTER_STOP
	var background = ColorRect.new()
	surface.add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.color = Color("#10191d")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var heading = make_label(surface,"TUTORIAL",23)
	heading.position = Vector2(20,12)
	subtitle = make_label(surface,"Hover or tap to learn. Scroll to zoom; middle-drag to pan. Arrow keys browse help.",13)
	subtitle.position = Vector2(20,44)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	close_button = make_button("CLOSE  /  ESC",close)
	reset_button = make_button("FIT IMAGE",reset_view)
	show_button = CheckButton.new()
	surface.add_child(show_button)
	show_button.text = "SHOW HOTSPOTS"
	show_button.add_theme_font_size_override("font_size",12)
	show_button.toggled.connect(func(_value):canvas.queue_redraw())
	canvas = BattleImage.new()
	canvas.panel = self
	surface.add_child(canvas)
	canvas.clip_contents = true
	canvas.mouse_filter = Control.MOUSE_FILTER_STOP
	canvas.focus_mode = Control.FOCUS_ALL
	canvas.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	canvas.gui_input.connect(image_input)
	canvas.mouse_exited.connect(func(): if not sticky: select_region(-1))
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH)) if FileAccess.file_exists(DATA_PATH) else null
	if parsed is Dictionary and parsed.get("schema_version",0)==1:
		image_size = Vector2(parsed.size[0],parsed.size[1])
		regions = parsed.regions
	# Imported game exports and the raw image in the private review pack both work.
	if ResourceLoader.exists(IMAGE_PATH):
		texture = ResourceLoader.load(IMAGE_PATH,"Texture2D") as Texture2D
	if texture == null and FileAccess.file_exists(IMAGE_PATH):
		var image = Image.load_from_file(IMAGE_PATH)
		if image != null: texture = ImageTexture.create_from_image(image)
	if texture == null or regions.is_empty():
		subtitle.text = "Tutorial image unavailable. Close this panel and reopen the sandbox after updating the game."
	# One tooltip, drawn above the image and never intercepting its pointer.
	tip = PanelContainer.new()
	surface.add_child(tip)
	tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tip.add_theme_stylebox_override("panel",box(Color("#192428"),TAN,14))
	var stack = VBoxContainer.new()
	tip.add_child(stack)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_theme_constant_override("separation",8)
	tip_title = make_label(stack,"",16)
	tip_title.add_theme_color_override("font_color",TAN)
	tip_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip_text = make_label(stack,"",16)
	tip_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.visible = false
	get_viewport().size_changed.connect(layout)
	layout()
	canvas.grab_focus()

func make_label(parent: Node, value: String, points: int) -> Label:
	var label = Label.new()
	parent.add_child(label)
	label.text = value
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",points)
	label.add_theme_color_override("font_color",INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func box(fill: Color, border: Color, padding: int = 8) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_content_margin_all(padding)
	style.shadow_color = Color(0,0,0,.4)
	style.shadow_size = 6
	return style

func make_button(value: String, action: Callable) -> Button:
	var button = Button.new()
	surface.add_child(button)
	button.text = value
	button.add_theme_font_override("font",font)
	button.add_theme_font_size_override("font_size",12)
	button.add_theme_stylebox_override("normal",box(Color("#263235"),Color("#687066")))
	button.add_theme_stylebox_override("hover",box(Color("#3c443b"),TAN))
	button.add_theme_stylebox_override("focus",box(Color(0,0,0,0),TAN))
	button.pressed.connect(action)
	return button

func layout() -> void:
	if canvas == null: return
	var viewport = get_viewport().get_visible_rect().size
	surface.size = viewport
	var narrow = viewport.x < 700
	var header = 130.0 if narrow else 78.0
	subtitle.size = Vector2(maxf(200,viewport.x-40),42 if narrow else 26)
	close_button.position = Vector2(viewport.x-148,10)
	close_button.size = Vector2(128,30)
	reset_button.position = Vector2(20 if narrow else viewport.x-436,88 if narrow else 10)
	reset_button.size = Vector2(98,30)
	show_button.position = Vector2(132 if narrow else viewport.x-326,86 if narrow else 10)
	show_button.size = Vector2(174,32)
	canvas.position = Vector2(12,header)
	canvas.size = Vector2(maxf(1,viewport.x-24),maxf(1,viewport.y-header-12))
	if viewport != last_size:
		zoom = 1.0
		pan = Vector2.ZERO
		last_size = viewport
		select_region(-1)
	canvas.queue_redraw()

func image_rect() -> Rect2:
	var fitted = minf(canvas.size.x/image_size.x,canvas.size.y/image_size.y)
	var dimensions = image_size*fitted*zoom
	return Rect2((canvas.size-dimensions)*.5+pan,dimensions)

func source_rect(row: Dictionary) -> Rect2:
	var r = row.rect
	return Rect2(r[0],r[1],r[2],r[3])

func region_rect(index: int) -> Rect2:
	var destination = image_rect()
	var source = source_rect(regions[index])
	return Rect2(destination.position+source.position*destination.size/image_size,source.size*destination.size/image_size)

func hit_test(at: Vector2) -> int:
	var destination = image_rect()
	if not Rect2(Vector2.ZERO,canvas.size).has_point(at) or not destination.has_point(at): return -1
	var point = (at-destination.position)*image_size/destination.size
	var found = -1
	for i in range(regions.size()):
		var row: Dictionary = regions[i]
		if not source_rect(row).has_point(point): continue
		if found < 0 or row.priority > regions[found].priority or (row.priority == regions[found].priority and source_rect(row).get_area() < source_rect(regions[found]).get_area()): found = i
	return found

func image_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pointer = event.position
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			pan += event.relative
			clamp_pan()
		sticky = false
		select_region(hit_test(pointer))
	elif event is InputEventMouseButton and event.pressed:
		pointer = event.position
		if event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:
			var old = image_rect()
			var anchor = (pointer-old.position)/old.size
			zoom = clampf(zoom*(1.2 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1./1.2),1.,3.)
			var changed = image_rect()
			pan += pointer-(changed.position+anchor*changed.size)
			clamp_pan()
			select_region(hit_test(pointer))
		elif event.button_index == MOUSE_BUTTON_LEFT:
			canvas.grab_focus()
			sticky = true
			select_region(hit_test(pointer))
		canvas.accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		pointer = event.position
		sticky = true
		select_region(hit_test(pointer))
		canvas.accept_event()
	elif event is InputEventKey and event.pressed and event.keycode in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN]:
		if regions.is_empty(): return
		var direction = -1 if event.keycode in [KEY_LEFT,KEY_UP] else 1
		reset_view()
		var next = posmod(active_index+direction,regions.size())
		pointer = region_rect(next).get_center()
		sticky = true
		select_region(next)
		canvas.accept_event()
	canvas.queue_redraw()

func clamp_pan() -> void:
	var extent = (image_rect().size-canvas.size).max(Vector2.ZERO)*.5
	pan = pan.clamp(-extent,extent)

func select_region(index: int) -> void:
	active_index = index
	if tip == null: return
	tip.visible = index >= 0
	if index >= 0:
		tip_title.text = regions[index].title
		tip_text.text = regions[index].text
		var width = minf(390.,surface.size.x-32.)
		tip_title.custom_minimum_size.x = width-28
		tip_text.custom_minimum_size.x = width-28
		tip.size = Vector2(width,0)
		place_tip.call_deferred()
	canvas.queue_redraw()

func place_tip() -> void:
	if active_index < 0 or not is_instance_valid(tip): return
	tip.reset_size()
	var target = region_rect(active_index)
	var anchor = canvas.position+pointer
	var at = anchor+Vector2(24,22)
	if at.x+tip.size.x > surface.size.x-12: at.x = anchor.x-tip.size.x-24
	if at.y+tip.size.y > surface.size.y-12: at.y = anchor.y-tip.size.y-22
	# Prefer placing above HUD controls to keep the hovered control fully visible.
	if source_rect(regions[active_index]).position.y > image_size.y*.72:
		at.y = canvas.position.y+target.position.y-tip.size.y-14
	at = at.clamp(Vector2(12,8),(surface.size-tip.size-Vector2(12,12)).max(Vector2(12,8)))
	tip.position = at

func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	canvas.queue_redraw()
	if active_index >= 0: place_tip.call_deferred()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		close()

func close() -> void:
	if previous_focus != null:
		var previous = previous_focus.get_ref()
		if is_instance_valid(previous): previous.grab_focus()
	queue_free()

class BattleImage extends Control:
	var panel
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO,size),Color("#0b1114"))
		if panel.texture == null: return
		draw_texture_rect(panel.texture,panel.image_rect(),false)
		if panel.show_button.button_pressed:
			for i in range(panel.regions.size()):
				if panel.regions[i].priority > 0: draw_rect(panel.region_rect(i),Color(.87,.79,.58,.32),false,1.)
		if panel.active_index < 0: return
		var rect: Rect2 = panel.region_rect(panel.active_index)
		# Several translucent rings make a subtle glow without blurring the image.
		for spread in [7.,5.,3.]: draw_rect(rect.grow(spread),Color(.90,.81,.59,.07),false,3.)
		draw_rect(rect,Color(.96,.86,.62,.09),true)
		draw_rect(rect,Color("#e6cf96"),false,2.)
