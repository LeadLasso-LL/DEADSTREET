extends Control
# Keep selection outside the round emblem material so the halo is never clipped.
var emblem: TextureRect
var selected: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	emblem = TextureRect.new()
	add_child(emblem)
	emblem.mouse_filter = Control.MOUSE_FILTER_IGNORE
	emblem.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	emblem.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	emblem.size = Vector2(16, 16)

func set_selected(value: bool) -> void:
	if selected == value:
		return
	selected = value
	queue_redraw()

func _draw() -> void:
	if not selected:
		return
	var center = Vector2(8, 8)
	for layer in range(4):
		draw_arc(center, 10.5 + layer, 0, TAU, 40, Color(1.0, .84, .27, .18 - layer * .04), 2.0, true)
	draw_arc(center, 9.5, 0, TAU, 40, Color("#f4d34e"), 1.5, true)
