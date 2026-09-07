extends SceneTree

# Headless Character Factory image validation, downsample, and non-canon style proofs.
# Does not touch gameplay, catalogs, or runtime bindings.
# Deterministic image processing only. Never sends pixels to a generative model.

const OPAQUE_ALPHA := 16
const MIN_OPAQUE_FRACTION := 0.02
const MAX_OPAQUE_FRACTION := 0.85
const CLIP_BORDER_PX := 2
const CLIP_SOLID_ALPHA := 80
const CLIP_FAIL_MIN_PIXELS := 16
const DIRECTIONS := ["e", "se", "s", "sw", "w", "nw", "n", "ne"]
const BAYER4 := [
	[0.0 / 16.0, 8.0 / 16.0, 2.0 / 16.0, 10.0 / 16.0],
	[12.0 / 16.0, 4.0 / 16.0, 14.0 / 16.0, 6.0 / 16.0],
	[3.0 / 16.0, 11.0 / 16.0, 1.0 / 16.0, 9.0 / 16.0],
	[15.0 / 16.0, 7.0 / 16.0, 13.0 / 16.0, 5.0 / 16.0]
]


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
	var post: Dictionary = daz.get("post_process", {}) if typeof(daz.get("post_process", {})) == TYPE_DICTIONARY else {}
	var profiles: Array = post.get("profiles", []) if typeof(post.get("profiles", [])) == TYPE_ARRAY else []
	var check_clip := not profiles.is_empty()
	var reports: Array = []
	var sources: Array[Image] = []
	for direction in DIRECTIONS:
		var file_name: String = "%s_%s_%s.png" % [variant_id, clip_id, direction]
		var src_path: String = source_dir.path_join(file_name)
		var check: Dictionary = _validate_source(src_path, check_clip)
		check["direction"] = direction
		check["path"] = src_path
		if not bool(check.get("ok", false)):
			check.erase("image")
			reports.append(check)
			return {
				"ok": false,
				"error_code": str(check.get("error_code", "PNG_ALPHA_FAILED")),
				"reason": str(check.get("reason", "source validation failed")),
				"failed_direction": direction,
				"images": reports
			}
		sources.append(check["image"])
		check.erase("image")
		reports.append(check)

	if profiles.is_empty():
		return _process_smoke(run_dir, variant_id, clip_id, sources, reports)

	return _process_proof(run_dir, variant_id, clip_id, post, sources, reports)


func _process_smoke(run_dir: String, variant_id: String, clip_id: String, sources: Array[Image], reports: Array) -> Dictionary:
	var out128: String = run_dir.path_join("128")
	DirAccess.make_dir_recursive_absolute(out128)
	var smalls: Array[Image] = []
	for i in sources.size():
		var small: Image = sources[i].duplicate()
		small.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var dest: String = out128.path_join("%s_%s_%s.png" % [variant_id, clip_id, DIRECTIONS[i]])
		var save_err: Error = small.save_png(dest)
		if save_err != OK:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "failed to save %s" % dest,
				"images": reports
			}
		smalls.append(small)
	var board_path: String = run_dir.path_join("%s_preview_board.png" % variant_id)
	var board_err: String = _write_simple_board(smalls, board_path)
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


func _process_proof(
	run_dir: String,
	variant_id: String,
	clip_id: String,
	post: Dictionary,
	sources: Array[Image],
	reports: Array
) -> Dictionary:
	var scale_heights: Array = post.get("scale_preview_heights_px", [96, 80, 64])
	var comparison_dir: String = str(post.get("comparison_direction", "se"))
	var boards_spec: Dictionary = post.get("boards", {}) if typeof(post.get("boards", {})) == TYPE_DICTIONARY else {}
	var clean_imgs: Array[Image] = []
	var grit_imgs: Array[Image] = []
	var digit_imgs: Array[Image] = []
	for i in sources.size():
		var src: Image = sources[i]
		var clean: Image = _profile_clean(src)
		var grit: Image = _profile_grounded_grit(src)
		var digit: Image = _profile_digitized_grit(grit)
		clean_imgs.append(clean)
		grit_imgs.append(grit)
		digit_imgs.append(digit)
		var named := {
			"clean_downsample": clean,
			"grounded_grit": grit,
			"digitized_grit": digit
		}
		for prof in named.keys():
			var img: Image = named[prof]
			var dir_path: String = run_dir.path_join("profiles").path_join(prof)
			DirAccess.make_dir_recursive_absolute(dir_path)
			var dest: String = dir_path.path_join("%s_%s_%s.png" % [variant_id, clip_id, DIRECTIONS[i]])
			if img.save_png(dest) != OK:
				return {
					"ok": false,
					"error_code": "GODOT_IMAGE_TOOL_FAILED",
					"reason": "failed to save %s" % dest,
					"images": reports
				}
			for h_value in scale_heights:
				var h: int = int(h_value)
				var scaled: Image = _presentation_at_height(img, h)
				var scale_dir: String = run_dir.path_join("scale").path_join(prof).path_join(str(h))
				DirAccess.make_dir_recursive_absolute(scale_dir)
				var scale_path: String = scale_dir.path_join("%s_%s_%s.png" % [variant_id, clip_id, DIRECTIONS[i]])
				if scaled.save_png(scale_path) != OK:
					return {
						"ok": false,
						"error_code": "GODOT_IMAGE_TOOL_FAILED",
						"reason": "failed to save %s" % scale_path,
						"images": reports
					}

	var board_paths := {}
	var names := {
		"clean_downsample": str(boards_spec.get("clean_downsample", "A_clean_downsample_board.png")),
		"grounded_grit": str(boards_spec.get("grounded_grit", "B_grounded_grit_board.png")),
		"digitized_grit": str(boards_spec.get("digitized_grit", "C_digitized_grit_board.png"))
	}
	var titles := {
		"clean_downsample": "A CLEAN DOWNSAMPLE  NON-CANON",
		"grounded_grit": "B GROUNDED GRIT  NON-CANON",
		"digitized_grit": "C DIGITIZED GRIT  NON-CANON"
	}
	var board_sprites := {
		"clean_downsample": clean_imgs,
		"grounded_grit": grit_imgs,
		"digitized_grit": digit_imgs
	}
	for prof in ["clean_downsample", "grounded_grit", "digitized_grit"]:
		var board_path: String = run_dir.path_join(names[prof])
		var err: String = _write_profile_board(
			board_sprites[prof],
			board_path,
			titles[prof],
			scale_heights
		)
		if not err.is_empty():
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": err,
				"images": reports
			}
		board_paths[prof] = board_path

	var cmp_name: String = str(boards_spec.get("comparison", "dead_street_rifleman_comparison_board.png"))
	var cmp_path: String = run_dir.path_join(cmp_name)
	var se_index: int = DIRECTIONS.find(comparison_dir)
	if se_index < 0:
		se_index = 1
	var cmp_err: String = _write_comparison_board(
		sources[se_index],
		clean_imgs[se_index],
		grit_imgs[se_index],
		digit_imgs[se_index],
		cmp_path,
		comparison_dir,
		scale_heights
	)
	if not cmp_err.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": cmp_err,
			"images": reports
		}
	board_paths["comparison"] = cmp_path
	return {
		"ok": true,
		"error_code": "",
		"reason": "eight source PNGs validated; three non-canon style profiles and preview boards written. No profile is accepted.",
		"preview_board": cmp_path,
		"preview_boards": board_paths,
		"profiles": ["clean_downsample", "grounded_grit", "digitized_grit"],
		"accepted_profile": "",
		"images": reports
	}


func _validate_source(path: String, check_clip: bool) -> Dictionary:
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
	var clipped := 0
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				transparent += 1
			else:
				opaque += 1
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
				if c.r + c.g + c.b > 0.12:
					lit += 1
				if check_clip and c.a * 255.0 >= CLIP_SOLID_ALPHA and (
					x < CLIP_BORDER_PX or y < CLIP_BORDER_PX
					or x >= img.get_width() - CLIP_BORDER_PX
					or y >= img.get_height() - CLIP_BORDER_PX
				):
					clipped += 1
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
	if check_clip and clipped >= CLIP_FAIL_MIN_PIXELS:
		return {
			"ok": false,
			"error_code": "CLIPPING_OUTSIDE_BOUNDS",
			"reason": "opaque pixels touch image border in %s (%d px)" % [path, clipped]
		}
	return {
		"ok": true,
		"opaque_fraction": opaque_frac,
		"transparent_pixels": transparent,
		"opaque_pixels": opaque,
		"bounds": [min_x, min_y, max_x, max_y],
		"image": img
	}


func _profile_clean(src: Image) -> Image:
	var small: Image = src.duplicate()
	small.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	return small


func _profile_grounded_grit(src: Image) -> Image:
	var work: Image = src.duplicate()
	work.convert(Image.FORMAT_RGBA8)
	var blurred: Image = _box_blur(work, 2)
	var treated := Image.create(work.get_width(), work.get_height(), false, Image.FORMAT_RGBA8)
	for y in work.get_height():
		for x in work.get_width():
			var c: Color = work.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				treated.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var b: Color = blurred.get_pixel(x, y)
			var luma := _luma(c)
			var blur_luma := _luma(b)
			# Compress high-frequency gloss toward the local neighborhood.
			if luma > blur_luma + 0.10:
				var pull: float = clampf((luma - blur_luma - 0.10) / 0.35, 0.0, 1.0) * 0.42
				c = c.lerp(b, pull)
				luma = _luma(c)
			# Mild desaturation.
			var gray := Color(luma, luma, luma, c.a)
			c = c.lerp(gray, 0.16)
			# Restrained local contrast.
			var local: float = luma - blur_luma
			c.r = clampf(c.r + local * 0.18, 0.0, 1.0)
			c.g = clampf(c.g + local * 0.18, 0.0, 1.0)
			c.b = clampf(c.b + local * 0.18, 0.0, 1.0)
			# Soft highlight compression.
			luma = _luma(c)
			if luma > 0.72:
				var knee: float = (luma - 0.72) / 0.28
				var scale: float = 1.0 - knee * 0.22
				c.r *= scale
				c.g *= scale
				c.b *= scale
			c.a = work.get_pixel(x, y).a
			treated.set_pixel(x, y, c)
	treated.resize(128, 128, Image.INTERPOLATE_LANCZOS)
	return _sharpen(treated, 0.22)


func _profile_digitized_grit(grounded_128: Image) -> Image:
	var img: Image = grounded_128.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	var levels := 26.0
	var out := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				out.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var dither: float = (BAYER4[y % 4][x % 4] - 0.5) * (0.55 / levels)
			c.r = _quantize(clampf(c.r + dither, 0.0, 1.0), levels)
			c.g = _quantize(clampf(c.g + dither, 0.0, 1.0), levels)
			c.b = _quantize(clampf(c.b + dither, 0.0, 1.0), levels)
			out.set_pixel(x, y, c)
	return _sharpen(out, 0.12)


func _quantize(v: float, levels: float) -> float:
	return clampf(roundf(v * levels) / levels, 0.0, 1.0)


func _luma(c: Color) -> float:
	return c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722


func _box_blur(src: Image, radius: int) -> Image:
	var w: int = src.get_width()
	var h: int = src.get_height()
	var tmp := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var out := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var span: int = radius * 2 + 1
	for y in h:
		for x in w:
			var acc := Color(0, 0, 0, 0)
			var n := 0
			for k in span:
				var xx: int = clampi(x + k - radius, 0, w - 1)
				acc += src.get_pixel(xx, y)
				n += 1
			tmp.set_pixel(x, y, acc / float(n))
	for y in h:
		for x in w:
			var acc := Color(0, 0, 0, 0)
			var n := 0
			for k in span:
				var yy: int = clampi(y + k - radius, 0, h - 1)
				acc += tmp.get_pixel(x, yy)
				n += 1
			out.set_pixel(x, y, acc / float(n))
	return out


func _sharpen(src: Image, amount: float) -> Image:
	var blur: Image = _box_blur(src, 1)
	var out := Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
	for y in src.get_height():
		for x in src.get_width():
			var c: Color = src.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				out.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var b: Color = blur.get_pixel(x, y)
			var s := Color(
				clampf(c.r + (c.r - b.r) * amount, 0.0, 1.0),
				clampf(c.g + (c.g - b.g) * amount, 0.0, 1.0),
				clampf(c.b + (c.b - b.b) * amount, 0.0, 1.0),
				c.a
			)
			out.set_pixel(x, y, s)
	return out


func _opaque_rect(img: Image) -> Rect2i:
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in img.get_height():
		for x in img.get_width():
			if img.get_pixel(x, y).a * 255.0 >= OPAQUE_ALPHA:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x:
		return Rect2i(0, 0, img.get_width(), img.get_height())
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _presentation_at_height(src: Image, target_h: int) -> Image:
	var bounds: Rect2i = _opaque_rect(src)
	if bounds.size.y <= 0:
		return src.duplicate()
	var scale: float = float(target_h) / float(bounds.size.y)
	var new_w: int = maxi(1, int(round(float(src.get_width()) * scale)))
	var new_h: int = maxi(1, int(round(float(src.get_height()) * scale)))
	var out: Image = src.duplicate()
	out.resize(new_w, new_h, Image.INTERPOLATE_LANCZOS)
	return out


func _nearest_scale(src: Image, factor: int) -> Image:
	var out: Image = src.duplicate()
	out.resize(src.get_width() * factor, src.get_height() * factor, Image.INTERPOLATE_NEAREST)
	return out


func _write_simple_board(sprites: Array[Image], dest: String) -> String:
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


func _write_profile_board(sprites: Array, dest: String, title: String, heights: Array) -> String:
	var cell := 128
	var gap := 18
	var margin := 24
	var label_h := 14
	var cols := 4
	var rows := 2
	var se: Image = sprites[1] if sprites.size() > 1 else sprites[0]
	var actuals: Array[Image] = []
	var enlargements: Array[Image] = []
	var max_actual_w := 0
	var row_h := 0
	for h_value in heights:
		var h: int = int(h_value)
		var actual: Image = _presentation_at_height(se, h)
		var enlarged: Image = _nearest_scale(actual, 3)
		actuals.append(actual)
		enlargements.append(enlarged)
		max_actual_w = maxi(max_actual_w, actual.get_width() + 16 + enlarged.get_width())
		row_h += maxi(actual.get_height(), enlarged.get_height()) + 28
	var grid_w: int = cols * cell + (cols - 1) * gap
	var w: int = margin * 2 + maxi(grid_w, max_actual_w + 80)
	var h: int = margin * 2 + 22 + rows * (cell + label_h) + (rows - 1) * gap + 36 + row_h
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.13, 0.13, 0.15, 1.0))
	_draw_text(board, margin, margin, title, Color(0.86, 0.86, 0.82, 1.0))
	var gy: int = margin + 22
	for i in sprites.size():
		var col: int = i % cols
		var row: int = int(i / cols)
		var ox: int = margin + col * (cell + gap)
		var oy: int = gy + row * (cell + label_h + gap)
		_draw_text(board, ox, oy, DIRECTIONS[i].to_upper(), Color(0.75, 0.75, 0.70, 1.0))
		_draw_checker(board, ox, oy + label_h, cell, cell)
		_blend_sprite(board, sprites[i], ox, oy + label_h)
	var ay: int = gy + rows * (cell + label_h + gap) + 8
	_draw_text(board, margin, ay, "ACTUAL SIZE  +  NEAREST NEIGHBOR 3X", Color(0.75, 0.75, 0.70, 1.0))
	ay += 16
	for i in actuals.size():
		var label: String = "%d PX TALL" % int(heights[i])
		_draw_text(board, margin, ay, label, Color(0.70, 0.70, 0.66, 1.0))
		var oy2: int = ay + 12
		_draw_checker(board, margin, oy2, actuals[i].get_width(), actuals[i].get_height())
		_blend_sprite(board, actuals[i], margin, oy2)
		var ex: int = margin + actuals[i].get_width() + 16
		_draw_checker(board, ex, oy2, enlargements[i].get_width(), enlargements[i].get_height())
		_blend_sprite(board, enlargements[i], ex, oy2)
		ay = oy2 + maxi(actuals[i].get_height(), enlargements[i].get_height()) + 16
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save %s" % dest
	return ""


func _write_comparison_board(
	raw512: Image,
	clean: Image,
	grit: Image,
	digit: Image,
	dest: String,
	direction: String,
	heights: Array
) -> String:
	var raw_show: Image = raw512.duplicate()
	raw_show.resize(256, 256, Image.INTERPOLATE_NEAREST)
	var margin := 24
	var gap := 18
	var labeled := [
		["RAW 512 SOURCE  SHOWN 256 NN", raw_show],
		["A CLEAN DOWNSAMPLE 128", clean],
		["B GROUNDED GRIT 128", grit],
		["C DIGITIZED GRIT 128", digit]
	]
	var actuals: Array[Image] = []
	var max_row_w := 256
	for h_value in heights:
		var actual: Image = _presentation_at_height(grit, int(h_value))
		actuals.append(actual)
		max_row_w = maxi(max_row_w, actual.get_width() + 16 + actual.get_width() * 4)
	var w: int = margin * 2 + max_row_w
	var h: int = margin * 2 + 28
	h += 256 + 22
	h += 3 * (128 + 22)
	h += 24
	for img in actuals:
		h += img.get_height() * 4 + 36
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.12, 0.12, 0.14, 1.0))
	_draw_text(board, margin, margin, "DEAD STREET RIFLEMAN COMPARISON  %s  NON-CANON  NO PROFILE ACCEPTED" % direction.to_upper(), Color(0.88, 0.88, 0.84, 1.0))
	var y: int = margin + 20
	for item in labeled:
		_draw_text(board, margin, y, str(item[0]), Color(0.74, 0.74, 0.70, 1.0))
		y += 12
		var img: Image = item[1]
		_draw_checker(board, margin, y, img.get_width(), img.get_height())
		_blend_sprite(board, img, margin, y)
		y += img.get_height() + 10
	_draw_text(board, margin, y, "ACTUAL GAMEPLAY-SCALE HEIGHTS  GROUNDED GRIT", Color(0.74, 0.74, 0.70, 1.0))
	y += 14
	for i in actuals.size():
		var actual: Image = actuals[i]
		var enlarged: Image = _nearest_scale(actual, 4)
		_draw_text(board, margin, y, "%d PX TALL   LEFT ACTUAL   RIGHT 4X NN" % int(heights[i]), Color(0.70, 0.70, 0.66, 1.0))
		y += 12
		_draw_checker(board, margin, y, actual.get_width(), actual.get_height())
		_blend_sprite(board, actual, margin, y)
		var ex: int = margin + actual.get_width() + 16
		_draw_checker(board, ex, y, enlarged.get_width(), enlarged.get_height())
		_blend_sprite(board, enlarged, ex, y)
		y += enlarged.get_height() + 12
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save comparison board"
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
			var px: int = ox + x
			var py: int = oy + y
			if px < 0 or py < 0 or px >= board.get_width() or py >= board.get_height():
				continue
			var src: Color = sprite.get_pixel(x, y)
			var dst: Color = board.get_pixel(px, py)
			var out := Color(
				lerpf(dst.r, src.r, src.a),
				lerpf(dst.g, src.g, src.a),
				lerpf(dst.b, src.b, src.a),
				1.0
			)
			board.set_pixel(px, py, out)


func _draw_text(board: Image, ox: int, oy: int, text: String, color: Color) -> void:
	var x: int = ox
	for i in text.length():
		var ch: String = text.substr(i, 1)
		_draw_glyph(board, x, oy, ch, color)
		x += 6


func _draw_glyph(board: Image, ox: int, oy: int, ch: String, color: Color) -> void:
	var rows: PackedStringArray = _glyph(ch)
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			if row[x] == "1":
				var px: int = ox + x
				var py: int = oy + y
				if px >= 0 and py >= 0 and px < board.get_width() and py < board.get_height():
					board.set_pixel(px, py, color)


func _glyph(ch: String) -> PackedStringArray:
	var key: String = ch.to_upper()
	var g := {
		" ": ["00000", "00000", "00000", "00000", "00000", "00000", "00000"],
		"A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
		"B": ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
		"C": ["01110", "10001", "10000", "10000", "10000", "10001", "01110"],
		"D": ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
		"E": ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
		"F": ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
		"G": ["01110", "10001", "10000", "10111", "10001", "10001", "01110"],
		"H": ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
		"I": ["11111", "00100", "00100", "00100", "00100", "00100", "11111"],
		"J": ["00111", "00010", "00010", "00010", "00010", "10010", "01100"],
		"K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
		"L": ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
		"M": ["10001", "11011", "10101", "10101", "10001", "10001", "10001"],
		"N": ["10001", "11001", "10101", "10011", "10001", "10001", "10001"],
		"O": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
		"P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
		"Q": ["01110", "10001", "10001", "10001", "10101", "10010", "01101"],
		"R": ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
		"S": ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
		"T": ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
		"U": ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
		"V": ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
		"W": ["10001", "10001", "10001", "10101", "10101", "10101", "01010"],
		"X": ["10001", "10001", "01010", "00100", "01010", "10001", "10001"],
		"Y": ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
		"Z": ["11111", "00001", "00010", "00100", "01000", "10000", "11111"],
		"0": ["01110", "10001", "10011", "10101", "11001", "10001", "01110"],
		"1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
		"2": ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
		"3": ["11110", "00001", "00001", "01110", "00001", "00001", "11110"],
		"4": ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
		"5": ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
		"6": ["01110", "10000", "11110", "10001", "10001", "10001", "01110"],
		"7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
		"8": ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
		"9": ["01110", "10001", "10001", "01111", "00001", "00001", "01110"],
		"-": ["00000", "00000", "00000", "11111", "00000", "00000", "00000"],
		"+": ["00000", "00100", "00100", "11111", "00100", "00100", "00000"]
	}
	if g.has(key):
		return PackedStringArray(g[key])
	return PackedStringArray(["11111", "10001", "10001", "10001", "10001", "10001", "11111"])


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
