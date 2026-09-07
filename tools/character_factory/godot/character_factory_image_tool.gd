extends SceneTree

# Headless Character Factory image validation + downsample.
# Does not touch gameplay, catalogs, or runtime bindings.

const OPAQUE_ALPHA := 16
const MIN_OPAQUE_FRACTION := 0.02
const MAX_OPAQUE_FRACTION := 0.85
const DIRECTIONS := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]


func _initialize() -> void:
	var code := 0
	var err: String = ""
	var payload: Dictionary = {}
	var parsed: Dictionary = _parse_args()
	var run_dir: String = str(parsed.get("run_dir", ""))
	if run_dir.is_empty():
		code = 2
		err = "missing --run-dir"
	else:
		var result: Dictionary = _process_run(run_dir)
		payload = result
		if not bool(result.get("ok", false)):
			code = 3
			err = str(result.get("reason", "GODOT_IMAGE_TOOL_FAILED"))
	_write_json(run_dir.path_join("image_validation.json"), payload if not payload.is_empty() else {
		"ok": false,
		"error_code": "GODOT_IMAGE_TOOL_FAILED",
		"reason": err
	})
	if not err.is_empty():
		printerr("character_factory_image_tool: %s" % err)
	quit(code)


func _parse_args() -> Dictionary:
	var out := {"run_dir": ""}
	var args: PackedStringArray = OS.get_cmdline_user_args()
	var i := 0
	while i < args.size():
		var token: String = args[i]
		if token == "--run-dir" and i + 1 < args.size():
			out["run_dir"] = args[i + 1]
			i += 2
			continue
		if token.begins_with("--run-dir="):
			out["run_dir"] = token.substr("--run-dir=".length())
			i += 1
			continue
		i += 1
	return out


func _process_run(run_dir: String) -> Dictionary:
	var daz_path: String = run_dir.path_join("daz_result.json")
	if not FileAccess.file_exists(daz_path):
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "daz_result.json missing"
		}
	var daz: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(daz_path))
	if typeof(daz) != TYPE_DICTIONARY:
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "daz_result.json is not an object"
		}
	var variant_id: String = str(daz.get("variant_id", "smoke_matt_01"))
	var clip_id: String = str(daz.get("clip_id", "idle"))
	var source_dir: String = str(daz.get("source_dir", run_dir.path_join("source")))
	var out128: String = run_dir.path_join("128")
	DirAccess.make_dir_recursive_absolute(out128)
	var reports: Array = []
	var source_images: Array[Image] = []
	for direction in DIRECTIONS:
		var file_name: String = "%s_%s_%s.png" % [variant_id, clip_id, direction]
		var src_path: String = source_dir.path_join(file_name)
		var check: Dictionary = _validate_source(src_path)
		check["direction"] = direction
		check["path"] = src_path
		reports.append(check)
		if not bool(check.get("ok", false)):
			return {
				"ok": false,
				"error_code": str(check.get("error_code", "PNG_ALPHA_FAILED")),
				"reason": str(check.get("reason", "source validation failed")),
				"failed_direction": direction,
				"images": reports
			}
		var img: Image = check["image"]
		check.erase("image")
		var small: Image = img.duplicate()
		small.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var dest: String = out128.path_join(file_name)
		var save_err: Error = small.save_png(dest)
		if save_err != OK:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "failed to save %s" % dest,
				"images": reports
			}
		source_images.append(small)
	var board_path: String = run_dir.path_join("%s_preview_board.png" % variant_id)
	var board_err: String = _write_board(source_images, board_path)
	if not board_err.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": board_err,
			"images": reports
		}
	return {
		"ok": true,
		"error_code": "",
		"reason": "eight source PNGs validated, downsampled, preview board written",
		"preview_board": board_path,
		"output_128_dir": out128,
		"images": reports
	}


func _validate_source(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {
			"ok": false,
			"error_code": "RENDER_FAILED",
			"reason": "missing %s" % path
		}
	var img := Image.new()
	var err: Error = img.load(path)
	if err != OK:
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "PNG decode failed for %s" % path
		}
	if img.get_width() != 512 or img.get_height() != 512:
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "expected 512x512, got %dx%d" % [img.get_width(), img.get_height()]
		}
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	var opaque := 0
	var transparent := 0
	var lit := 0
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				transparent += 1
			else:
				opaque += 1
				if c.r + c.g + c.b > 0.12:
					lit += 1
	var total: int = img.get_width() * img.get_height()
	var opaque_frac: float = float(opaque) / float(total)
	if transparent <= 0:
		return {
			"ok": false,
			"error_code": "PNG_ALPHA_FAILED",
			"reason": "no transparent pixels in %s" % path
		}
	if opaque <= 0 or lit <= 0:
		return {
			"ok": false,
			"error_code": "PNG_ALPHA_FAILED",
			"reason": "image is blank in %s" % path
		}
	if opaque_frac < MIN_OPAQUE_FRACTION or opaque_frac > MAX_OPAQUE_FRACTION:
		return {
			"ok": false,
			"error_code": "PNG_ALPHA_FAILED",
			"reason": "implausible figure occupancy %.4f in %s" % [opaque_frac, path]
		}
	return {
		"ok": true,
		"opaque_fraction": opaque_frac,
		"transparent_pixels": transparent,
		"opaque_pixels": opaque,
		"image": img
	}


func _write_board(sprites: Array[Image], dest: String) -> String:
	var cell := 128
	var gap := 24
	var margin := 24
	var cols := 4
	var rows := 2
	var w: int = margin * 2 + cols * cell + (cols - 1) * gap
	var h: int = margin * 2 + rows * cell + (rows - 1) * gap
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.14, 0.14, 0.16, 1.0))
	for i in sprites.size():
		var col: int = i % cols
		var row: int = int(i / cols)
		var ox: int = margin + col * (cell + gap)
		var oy: int = margin + row * (cell + gap)
		_draw_checker(board, ox, oy, cell, cell)
		_blend_sprite(board, sprites[i], ox, oy)
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save preview board"
	return ""


func _draw_checker(board: Image, ox: int, oy: int, w: int, h: int) -> void:
	var a := Color(0.22, 0.22, 0.24, 1.0)
	var b := Color(0.10, 0.10, 0.12, 1.0)
	var size := 8
	for y in h:
		for x in w:
			var use_a: bool = ((int(x / size) + int(y / size)) % 2) == 0
			board.set_pixel(ox + x, oy + y, a if use_a else b)


func _blend_sprite(board: Image, sprite: Image, ox: int, oy: int) -> void:
	for y in sprite.get_height():
		for x in sprite.get_width():
			var src: Color = sprite.get_pixel(x, y)
			var dst: Color = board.get_pixel(ox + x, oy + y)
			var out := Color(
				lerpf(dst.r, src.r, src.a),
				lerpf(dst.g, src.g, src.a),
				lerpf(dst.b, src.b, src.a),
				1.0
			)
			board.set_pixel(ox + x, oy + y, out)


func _write_json(path: String, data: Dictionary) -> void:
	if path.get_base_dir().is_empty():
		return
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		printerr("character_factory_image_tool: cannot write %s" % path)
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
