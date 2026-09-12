extends SceneTree

# Each worker owns one manifest and output directory; no shared jobs files.
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		quit(2)
		return
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	var atlases: Dictionary = {}
	var borders: Array = []
	var empty: Array = []
	for job: Array in data.jobs:
		var im := Image.new()
		if im.load_svg_from_string(str(job[0]), 2.0) != OK:
			push_error(str(job[4]))
			quit(1)
			return
		im.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var bounds := im.get_used_rect()
		if bounds.size == Vector2i.ZERO:
			empty.append(job[4])
		if bounds.position.x <= 0 or bounds.end.x >= 128 or bounds.position.y <= 0 or bounds.end.y >= 128:
			borders.append(job[4])
		var key: String = str(job[1])
		if not atlases.has(key):
			var height: int = 6144 if key in ["units", "blood_masks"] else 1024
			atlases[key] = Image.create(4096, height, false, Image.FORMAT_RGBA8)
		atlases[key].blit_rect(im, Rect2i(0, 0, 128, 128), Vector2i(job[2], job[3]))
	for key: String in atlases:
		if atlases[key].save_png(str(data.output) + "/" + key + ".png") != OK:
			quit(1)
			return
	var file := FileAccess.open(str(data.output) + "/render.json", FileAccess.WRITE)
	file.store_string(JSON.stringify({"frames": data.jobs.size(), "borders": borders, "empty": empty}))
	file.close()
	print("ROSTER_RENDER ", data.variant, " frames=", data.jobs.size(), " borders=", borders.size())
	quit(1 if not empty.is_empty() else 0)
