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
	if str(post.get("kind", "")) == "camera_pose_calibration":
		return _process_calibration(run_dir, daz, post)
	if str(post.get("kind", "")) == "rifle_silhouette_calibration":
		return _process_silhouette(run_dir, daz, post)
	if str(post.get("kind", "")) == "style_conversion":
		return _process_style_conversion(run_dir, daz, post)
	if str(post.get("kind", "")) == "integrity_proof":
		return _process_integrity_proof(run_dir, daz, post)

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


func _process_calibration(run_dir: String, daz: Dictionary, post: Dictionary) -> Dictionary:
	var cells_raw: Variant = daz.get("calibration_cells", [])
	if typeof(cells_raw) != TYPE_ARRAY or cells_raw.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "calibration_cells missing from daz_result.json"
		}
	var reports: Array = []
	var matrix: Array = []
	for cell_value in cells_raw:
		if typeof(cell_value) != TYPE_DICTIONARY:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "calibration cell is not an object"
			}
		var cell: Dictionary = cell_value
		var src_path: String = str(cell.get("path", ""))
		var check: Dictionary = _validate_source(src_path, true)
		check["camera_id"] = str(cell.get("camera_id", ""))
		check["pose_id"] = str(cell.get("pose_id", ""))
		check["path"] = src_path
		if not bool(check.get("ok", false)):
			check.erase("image")
			reports.append(check)
			return {
				"ok": false,
				"error_code": str(check.get("error_code", "PNG_ALPHA_FAILED")),
				"reason": str(check.get("reason", "calibration source failed")),
				"images": reports
			}
		var src: Image = check["image"]
		check.erase("image")
		var grit: Image = _profile_grounded_grit(src)
		var dest_dir: String = run_dir.path_join("profiles").path_join("grounded_grit")
		DirAccess.make_dir_recursive_absolute(dest_dir)
		var dest: String = dest_dir.path_join("%s_%s_%s_se.png" % [
			str(daz.get("variant_id", "local_street_gang_rifleman_proof_01")),
			str(cell.get("camera_id", "")),
			str(cell.get("pose_id", ""))
		])
		if grit.save_png(dest) != OK:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "failed to save %s" % dest,
				"images": reports
			}
		var dest128_dir: String = run_dir.path_join("128").path_join("grounded_grit")
		DirAccess.make_dir_recursive_absolute(dest128_dir)
		var img128: Image = grit.duplicate()
		img128.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var dest128: String = dest128_dir.path_join("%s_%s_se.png" % [str(cell.get("camera_id", "")), str(cell.get("pose_id", ""))])
		if img128.save_png(dest128) != OK:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "failed to save %s" % dest128,
				"images": reports
			}
		for h_value in [96, 80, 64]:
			var scaled: Image = _presentation_at_height(grit, int(h_value))
			var scale_dir: String = run_dir.path_join("scale").path_join("grounded_grit").path_join(str(int(h_value)))
			DirAccess.make_dir_recursive_absolute(scale_dir)
			var scale_path: String = scale_dir.path_join("%s_%s_se.png" % [str(cell.get("camera_id", "")), str(cell.get("pose_id", ""))])
			if scaled.save_png(scale_path) != OK:
				return {
					"ok": false,
					"error_code": "GODOT_IMAGE_TOOL_FAILED",
					"reason": "failed to save %s" % scale_path,
					"images": reports
				}
		reports.append(check)
		matrix.append({
			"camera_id": str(cell.get("camera_id", "")),
			"pose_id": str(cell.get("pose_id", "")),
			"pose_label": str(cell.get("pose_label", cell.get("pose_id", ""))),
			"elevation_deg": cell.get("elevation_deg", 0),
			"grit": grit
		})
	if matrix.size() != 9:
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "expected 9 calibration cells, got %d" % matrix.size(),
			"images": reports
		}
	var boards_spec: Dictionary = post.get("boards", {}) if typeof(post.get("boards", {})) == TYPE_DICTIONARY else {}
	var matrix_path: String = run_dir.path_join(str(boards_spec.get("matrix", "camera_pose_calibration_board.png")))
	var actual_path: String = run_dir.path_join(str(boards_spec.get("actual_scale", "camera_pose_calibration_actual_scale.png")))
	var matrix_err: String = _write_calibration_matrix_board(matrix, matrix_path)
	if not matrix_err.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": matrix_err,
			"images": reports
		}
	var actual_err: String = _write_calibration_actual_scale_board(matrix, actual_path)
	if not actual_err.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": actual_err,
			"images": reports
		}
	return {
		"ok": true,
		"error_code": "",
		"reason": "nine calibration sources validated with grounded_grit only. No camera or pose is accepted.",
		"preview_board": matrix_path,
		"preview_boards": {
			"matrix": matrix_path,
			"actual_scale": actual_path
		},
		"accepted_camera": "",
		"accepted_pose": "",
		"images": reports
	}


func _process_silhouette(run_dir: String, daz: Dictionary, post: Dictionary) -> Dictionary:
	var cells_raw: Variant = daz.get("calibration_cells", [])
	if typeof(cells_raw) != TYPE_ARRAY or cells_raw.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "calibration_cells missing from daz_result.json"
		}
	var reports: Array = []
	var matrix: Array = []
	for cell_value in cells_raw:
		if typeof(cell_value) != TYPE_DICTIONARY:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "calibration cell is not an object"
			}
		var cell: Dictionary = cell_value
		var src_path: String = str(cell.get("path", ""))
		var check: Dictionary = _validate_source(src_path, true)
		check["camera_id"] = str(cell.get("camera_id", ""))
		check["pose_id"] = str(cell.get("pose_id", ""))
		check["path"] = src_path
		if not bool(check.get("ok", false)):
			check.erase("image")
			reports.append(check)
			return {
				"ok": false,
				"error_code": str(check.get("error_code", "PNG_ALPHA_FAILED")),
				"reason": str(check.get("reason", "silhouette source failed")),
				"images": reports
			}
		var src: Image = check["image"]
		check.erase("image")
		var grit: Image = _profile_grounded_grit(src)
		var dest_dir: String = run_dir.path_join("profiles").path_join("grounded_grit")
		DirAccess.make_dir_recursive_absolute(dest_dir)
		var dest: String = dest_dir.path_join("%s_%s_%s_se.png" % [
			str(daz.get("variant_id", "local_street_gang_rifleman_proof_01")),
			str(cell.get("camera_id", "")),
			str(cell.get("pose_id", ""))
		])
		if grit.save_png(dest) != OK:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "failed to save %s" % dest,
				"images": reports
			}
		var dest128_dir: String = run_dir.path_join("128").path_join("grounded_grit")
		DirAccess.make_dir_recursive_absolute(dest128_dir)
		var img128: Image = grit.duplicate()
		img128.resize(128, 128, Image.INTERPOLATE_LANCZOS)
		var dest128: String = dest128_dir.path_join("%s_se.png" % str(cell.get("pose_id", "")))
		if img128.save_png(dest128) != OK:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "failed to save %s" % dest128,
				"images": reports
			}
		for h_value in [96, 80, 64]:
			var scaled: Image = _presentation_at_height(grit, int(h_value))
			var scale_dir: String = run_dir.path_join("scale").path_join("grounded_grit").path_join(str(int(h_value)))
			DirAccess.make_dir_recursive_absolute(scale_dir)
			var scale_path: String = scale_dir.path_join("%s_se.png" % str(cell.get("pose_id", "")))
			if scaled.save_png(scale_path) != OK:
				return {
					"ok": false,
					"error_code": "GODOT_IMAGE_TOOL_FAILED",
					"reason": "failed to save %s" % scale_path,
					"images": reports
				}
		reports.append(check)
		matrix.append({
			"camera_id": str(cell.get("camera_id", "")),
			"pose_id": str(cell.get("pose_id", "")),
			"pose_label": str(cell.get("pose_label", cell.get("pose_id", ""))),
			"elevation_deg": cell.get("elevation_deg", 0),
			"grit": grit
		})
	if matrix.size() != 3:
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "expected 3 hybrid silhouette cells, got %d" % matrix.size(),
			"images": reports
		}
	var boards_spec: Dictionary = post.get("boards", {}) if typeof(post.get("boards", {})) == TYPE_DICTIONARY else {}
	var matrix_path: String = run_dir.path_join(str(boards_spec.get("matrix", "rifle_silhouette_calibration_board.png")))
	var actual_path: String = run_dir.path_join(str(boards_spec.get("actual_scale", "rifle_silhouette_actual_scale.png")))
	var matrix_err: String = _write_silhouette_board(matrix, matrix_path)
	if not matrix_err.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": matrix_err,
			"images": reports
		}
	var actual_err: String = _write_silhouette_actual_scale_board(matrix, actual_path)
	if not actual_err.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": actual_err,
			"images": reports
		}
	return {
		"ok": true,
		"error_code": "",
		"reason": "three hybrid silhouette sources validated with grounded_grit only. Camera 56 is provisional. No pose is accepted.",
		"preview_board": matrix_path,
		"preview_boards": {
			"matrix": matrix_path,
			"actual_scale": actual_path
		},
		"accepted_camera": "",
		"accepted_pose": "",
		"images": reports
	}


func _process_style_conversion(run_dir: String, daz: Dictionary, post: Dictionary) -> Dictionary:
	var cells_raw: Variant = daz.get("style_sources", [])
	if typeof(cells_raw) != TYPE_ARRAY or cells_raw.is_empty():
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "style_sources missing from daz_result.json"
		}
	var source_order := ["SOURCE_0", "SOURCE_1", "SOURCE_2"]
	var post_order := ["POST_0", "POST_1", "POST_2"]
	var sources: Dictionary = {}
	var reports: Array = []
	for cell_value in cells_raw:
		if typeof(cell_value) != TYPE_DICTIONARY:
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "style source cell is not an object"
			}
		var cell: Dictionary = cell_value
		var src_path: String = str(cell.get("path", ""))
		var check: Dictionary = _validate_source(src_path, true)
		check["source_id"] = str(cell.get("source_id", ""))
		check["path"] = src_path
		if not bool(check.get("ok", false)):
			check.erase("image")
			reports.append(check)
			return {
				"ok": false,
				"error_code": str(check.get("error_code", "PNG_ALPHA_FAILED")),
				"reason": str(check.get("reason", "style source failed")),
				"images": reports
			}
		var img: Image = check["image"]
		check.erase("image")
		reports.append(check)
		sources[str(cell.get("source_id", ""))] = {
			"cell": cell,
			"image": img
		}
	for sid in source_order:
		if not sources.has(sid):
			return {
				"ok": false,
				"error_code": "GODOT_IMAGE_TOOL_FAILED",
				"reason": "missing style source %s" % sid,
				"images": reports
			}
	var matrix: Array = []
	var metrics: Array = []
	for sid in source_order:
		var pack: Dictionary = sources[sid]
		var src_img: Image = pack["image"]
		var src_cell: Dictionary = pack["cell"]
		var post0: Image = _profile_post_clean(src_img)
		var post1: Image = _profile_shape_compressed(src_img)
		var post2: Image = _profile_digitized_structure(post1)
		var treated := {"POST_0": post0, "POST_1": post1, "POST_2": post2}
		for pid in post_order:
			var processed: Image = treated[pid]
			var dest_dir: String = run_dir.path_join("profiles").path_join(pid)
			DirAccess.make_dir_recursive_absolute(dest_dir)
			var dest: String = dest_dir.path_join("%s_%s_se.png" % [sid, pid])
			if processed.save_png(dest) != OK:
				return {
					"ok": false,
					"error_code": "GODOT_IMAGE_TOOL_FAILED",
					"reason": "failed to save %s" % dest,
					"images": reports
				}
			var dest128_dir: String = run_dir.path_join("128").path_join(pid)
			DirAccess.make_dir_recursive_absolute(dest128_dir)
			var img128: Image = processed.duplicate()
			img128.resize(128, 128, Image.INTERPOLATE_LANCZOS)
			if pid == "POST_0":
				img128 = _sharpen(img128, 0.16)
			var dest128: String = dest128_dir.path_join("%s_se.png" % sid)
			if img128.save_png(dest128) != OK:
				return {
					"ok": false,
					"error_code": "GODOT_IMAGE_TOOL_FAILED",
					"reason": "failed to save %s" % dest128,
					"images": reports
				}
			for h_value in [96, 80, 64]:
				var scaled: Image = _presentation_at_height(processed, int(h_value))
				var scale_dir: String = run_dir.path_join("scale").path_join(pid).path_join(str(int(h_value)))
				DirAccess.make_dir_recursive_absolute(scale_dir)
				var scale_path: String = scale_dir.path_join("%s_se.png" % sid)
				if scaled.save_png(scale_path) != OK:
					return {
						"ok": false,
						"error_code": "GODOT_IMAGE_TOOL_FAILED",
						"reason": "failed to save %s" % scale_path,
						"images": reports
					}
			var metric: Dictionary = _style_metrics(processed)
			metric["source_id"] = sid
			metric["post_id"] = pid
			metric["source_path"] = str(src_cell.get("path", ""))
			metrics.append(metric)
			matrix.append({
				"source_id": sid,
				"source_label": str(src_cell.get("source_label", sid)),
				"post_id": pid,
				"processed": processed
			})
	if matrix.size() != 9:
		return {
			"ok": false,
			"error_code": "GODOT_IMAGE_TOOL_FAILED",
			"reason": "expected 9 style combinations, got %d" % matrix.size(),
			"images": reports
		}
	var boards_spec: Dictionary = post.get("boards", {}) if typeof(post.get("boards", {})) == TYPE_DICTIONARY else {}
	var matrix_path: String = run_dir.path_join(str(boards_spec.get("matrix", "style_conversion_matrix.png")))
	var actual_path: String = run_dir.path_join(str(boards_spec.get("actual_scale", "style_conversion_actual_scale.png")))
	var source_board_path: String = run_dir.path_join(str(boards_spec.get("source", "style_conversion_source_comparison.png")))
	var matrix_err: String = _write_style_matrix_board(matrix, matrix_path)
	if not matrix_err.is_empty():
		return {"ok": false, "error_code": "GODOT_IMAGE_TOOL_FAILED", "reason": matrix_err, "images": reports}
	var actual_err: String = _write_style_actual_scale_board(matrix, actual_path)
	if not actual_err.is_empty():
		return {"ok": false, "error_code": "GODOT_IMAGE_TOOL_FAILED", "reason": actual_err, "images": reports}
	var src_imgs: Array = []
	for sid2 in source_order:
		var src_pack: Dictionary = sources[sid2]
		var src_cell2: Dictionary = src_pack["cell"]
		src_imgs.append({
			"id": sid2,
			"label": str(src_cell2.get("source_label", sid2)),
			"image": src_pack["image"]
		})
	var src_err: String = _write_style_source_board(src_imgs, source_board_path)
	if not src_err.is_empty():
		return {"ok": false, "error_code": "GODOT_IMAGE_TOOL_FAILED", "reason": src_err, "images": reports}
	_write_json(run_dir.path_join("style_metrics.json"), {"ok": true, "accepted_style": "", "metrics": metrics})
	return {
		"ok": true,
		"error_code": "",
		"reason": "three DAZ sources and nine style combinations validated. No style is accepted.",
		"preview_board": matrix_path,
		"preview_boards": {
			"matrix": matrix_path,
			"actual_scale": actual_path,
			"source": source_board_path
		},
		"accepted_style": "",
		"images": reports
	}


func _composite_on_bg(src: Image, bg: Color) -> Image:
	var out := Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
	out.fill(bg)
	for y in src.get_height():
		for x in src.get_width():
			var c: Color = src.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var dst: Color = out.get_pixel(x, y)
			out.set_pixel(x, y, Color(
				dst.r * (1.0 - c.a) + c.r * c.a,
				dst.g * (1.0 - c.a) + c.g * c.a,
				dst.b * (1.0 - c.a) + c.b * c.a,
				1.0
			))
	return out


func _alpha_vis(src: Image) -> Image:
	var out := Image.create(src.get_width(), src.get_height(), false, Image.FORMAT_RGBA8)
	for y in src.get_height():
		for x in src.get_width():
			var a: float = src.get_pixel(x, y).a
			out.set_pixel(x, y, Color(a, a, a, 1.0))
	return out


func _load_png_loose(path: String) -> Image:
	if path.is_empty() or not FileAccess.file_exists(path):
		return null
	var img := Image.new()
	if img.load(path) != OK:
		return null
	img.convert(Image.FORMAT_RGBA8)
	return img


func _blit(dst: Image, src: Image, ox: int, oy: int) -> void:
	if src == null:
		return
	for y in src.get_height():
		for x in src.get_width():
			dst.set_pixel(ox + x, oy + y, src.get_pixel(x, y))


func _integrity_alpha_stats(img: Image) -> Dictionary:
	var out := {}
	for thresh in [16, 80, 128, 240]:
		var n := 0
		var min_x := img.get_width()
		var min_y := img.get_height()
		var max_x := -1
		var max_y := -1
		var border := 0
		for y in img.get_height():
			for x in img.get_width():
				if img.get_pixel(x, y).a * 255.0 < float(thresh):
					continue
				n += 1
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
				if x == 0 or y == 0 or x == img.get_width() - 1 or y == img.get_height() - 1:
					border += 1
		out[str(thresh)] = {
			"count": n,
			"bounds": [min_x, min_y, max_x, max_y] if n > 0 else [],
			"size": [max_x - min_x + 1, max_y - min_y + 1] if n > 0 else [0, 0],
			"border": border
		}
	return out


func _process_integrity_proof(run_dir: String, daz: Dictionary, post: Dictionary) -> Dictionary:
	var files_raw: Variant = daz.get("render_files", [])
	if typeof(files_raw) != TYPE_ARRAY or files_raw.is_empty():
		return {"ok": false, "error_code": "GODOT_IMAGE_TOOL_FAILED", "reason": "integrity render_files missing"}
	var loaded: Array = []
	var reports: Array = []
	var stats := {}
	for path_value in files_raw:
		var path: String = str(path_value)
		var img: Image = _load_png_loose(path)
		if img == null:
			return {"ok": false, "error_code": "RENDER_FAILED", "reason": "missing integrity png %s" % path}
		var st: Dictionary = _integrity_alpha_stats(img)
		stats[path.get_file()] = st
		reports.append({"path": path, "ok": true, "alpha": st})
		loaded.append({"path": path, "image": img, "name": path.get_file()})
	var orig_dir: String = run_dir.path_join("original_v13")
	var orig2: Image = _load_png_loose(orig_dir.path_join("local_street_gang_rifleman_proof_01_SOURCE_2_se.png"))
	if orig2 != null:
		stats["original_SOURCE_2"] = _integrity_alpha_stats(orig2)
		loaded.push_front({"path": orig_dir.path_join("local_street_gang_rifleman_proof_01_SOURCE_2_se.png"), "image": orig2, "name": "original_v13_SOURCE_2"})
	var cell := 256
	var cols := 4
	var rows: int = loaded.size()
	var board := Image.create(cols * cell + 8, rows * cell + 8, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.12, 0.12, 0.13, 1.0))
	var bgs: Array[Color] = [Color(0.94, 0.93, 0.89), Color(0.50, 0.50, 0.50), Color(0.10, 0.10, 0.10)]
	for r in rows:
		var src: Image = loaded[r]["image"]
		var small: Image = src.duplicate()
		small.resize(cell, cell, Image.INTERPOLATE_NEAREST)
		for c in 3:
			var comp: Image = _composite_on_bg(small, bgs[c])
			_blit(board, comp, c * cell, r * cell)
		var av: Image = _alpha_vis(small)
		_blit(board, av, 3 * cell, r * cell)
	var board_name := "integrity_comparison_board.png"
	var boards: Variant = post.get("boards", {})
	if typeof(boards) == TYPE_DICTIONARY and str(boards.get("comparison", "")) != "":
		board_name = str(boards.get("comparison"))
	var board_path: String = run_dir.path_join(board_name)
	if board.save_png(board_path) != OK:
		return {"ok": false, "error_code": "GODOT_IMAGE_TOOL_FAILED", "reason": "failed to save %s" % board_path}
	_write_json(run_dir.path_join("integrity_alpha_stats.json"), {"ok": true, "accepted_style": "", "stats": stats})
	return {
		"ok": true,
		"error_code": "",
		"reason": "integrity diagnostic board written. Isolation is not a production source. No style is accepted.",
		"preview_board": board_path,
		"preview_boards": {"comparison": board_path},
		"accepted_style": "",
		"images": reports
	}


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


func _profile_post_clean(src: Image) -> Image:
	var work: Image = src.duplicate()
	work.convert(Image.FORMAT_RGBA8)
	return work


func _profile_shape_compressed(src: Image) -> Image:
	var work: Image = src.duplicate()
	work.convert(Image.FORMAT_RGBA8)
	var blurred: Image = _box_blur(work, 3)
	var treated := Image.create(work.get_width(), work.get_height(), false, Image.FORMAT_RGBA8)
	for y in work.get_height():
		for x in work.get_width():
			var c: Color = work.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				treated.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var b: Color = blurred.get_pixel(x, y)
			# Collapse high-frequency photographic variation toward local form.
			c = c.lerp(b, 0.38)
			var luma := _luma(c)
			var blur_luma := _luma(b)
			var gray := Color(luma, luma, luma, c.a)
			c = c.lerp(gray, 0.28)
			# Stronger broad light/shadow grouping.
			var local: float = luma - blur_luma
			if local > 0.045:
				c = c.lerp(Color(clampf(c.r + 0.05, 0.0, 1.0), clampf(c.g + 0.05, 0.0, 1.0), clampf(c.b + 0.045, 0.0, 1.0), c.a), 0.35)
			elif local < -0.045:
				c = c.lerp(Color(c.r * 0.82, c.g * 0.82, c.b * 0.84, c.a), 0.40)
			c.r = clampf(c.r + local * 0.22, 0.0, 1.0)
			c.g = clampf(c.g + local * 0.22, 0.0, 1.0)
			c.b = clampf(c.b + local * 0.20, 0.0, 1.0)
			luma = _luma(c)
			# Tonal compression: lift crushed shadows, roll highlights, keep rifle readable.
			if luma < 0.10:
				var lift: float = (0.10 - luma) * 0.45
				c.r = clampf(c.r + lift, 0.0, 1.0)
				c.g = clampf(c.g + lift, 0.0, 1.0)
				c.b = clampf(c.b + lift, 0.0, 1.0)
			luma = _luma(c)
			if luma > 0.68:
				var knee: float = (luma - 0.68) / 0.32
				var scale: float = 1.0 - knee * 0.28
				c.r *= scale
				c.g *= scale
				c.b *= scale
			# Bounded quantization, not retro.
			c.r = _quantize(c.r, 42.0)
			c.g = _quantize(c.g, 42.0)
			c.b = _quantize(c.b, 42.0)
			c.a = work.get_pixel(x, y).a
			treated.set_pixel(x, y, c)
	return _sharpen(treated, 0.14)


func _profile_digitized_structure(shape_compressed: Image) -> Image:
	var img: Image = shape_compressed.duplicate()
	img.convert(Image.FORMAT_RGBA8)
	var levels := 20.0
	var quantized := Image.create(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
	for y in img.get_height():
		for x in img.get_width():
			var c: Color = img.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				quantized.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var dither: float = (BAYER4[y % 4][x % 4] - 0.5) * (0.42 / levels)
			c.r = _quantize(clampf(c.r + dither, 0.0, 1.0), levels)
			c.g = _quantize(clampf(c.g + dither, 0.0, 1.0), levels)
			c.b = _quantize(clampf(c.b + dither, 0.0, 1.0), levels)
			quantized.set_pixel(x, y, c)
	var clustered: Image = _snap_isolated_pixels(quantized)
	return _sharpen(clustered, 0.20)


func _snap_isolated_pixels(src: Image) -> Image:
	var out: Image = src.duplicate()
	var w: int = src.get_width()
	var h: int = src.get_height()
	for y in h:
		for x in w:
			var c: Color = src.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				continue
			var counts: Dictionary = {}
			var nbs: Array[Color] = []
			var offsets := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			for off in offsets:
				var nx: int = x + off.x
				var ny: int = y + off.y
				if nx < 0 or ny < 0 or nx >= w or ny >= h:
					continue
				var nb: Color = src.get_pixel(nx, ny)
				if nb.a * 255.0 < OPAQUE_ALPHA:
					continue
				nbs.append(nb)
				var key := "%d,%d,%d" % [int(round(nb.r * 20.0)), int(round(nb.g * 20.0)), int(round(nb.b * 20.0))]
				counts[key] = int(counts.get(key, 0)) + 1
			if nbs.size() < 3:
				continue
			var self_key := "%d,%d,%d" % [int(round(c.r * 20.0)), int(round(c.g * 20.0)), int(round(c.b * 20.0))]
			var best_key := ""
			var best_n := 0
			for k in counts.keys():
				if int(counts[k]) > best_n:
					best_n = int(counts[k])
					best_key = str(k)
			if best_n >= 3 and best_key != self_key:
				var parts: PackedStringArray = best_key.split(",")
				out.set_pixel(x, y, Color(float(parts[0]) / 20.0, float(parts[1]) / 20.0, float(parts[2]) / 20.0, c.a))
	return out


func _sat(c: Color) -> float:
	var mx: float = maxf(c.r, maxf(c.g, c.b))
	var mn: float = minf(c.r, minf(c.g, c.b))
	if mx <= 0.0001:
		return 0.0
	return (mx - mn) / mx


func _style_metrics(img: Image) -> Dictionary:
	var unique := {}
	var opaque := 0
	var edges := 0
	var dark := 0
	var bright := 0
	var sat_sum := 0.0
	var luma_min := 1.0
	var luma_max := 0.0
	var w: int = img.get_width()
	var h: int = img.get_height()
	for y in h:
		for x in w:
			var c: Color = img.get_pixel(x, y)
			if c.a * 255.0 < OPAQUE_ALPHA:
				continue
			opaque += 1
			var key := (int(c.r * 255.0) << 16) | (int(c.g * 255.0) << 8) | int(c.b * 255.0)
			unique[key] = true
			var luma := _luma(c)
			luma_min = minf(luma_min, luma)
			luma_max = maxf(luma_max, luma)
			sat_sum += _sat(c)
			if luma < 0.08:
				dark += 1
			if luma > 0.85:
				bright += 1
			if x + 1 < w:
				var rgt: Color = img.get_pixel(x + 1, y)
				if rgt.a * 255.0 >= OPAQUE_ALPHA and absf(luma - _luma(rgt)) > 0.12:
					edges += 1
			if y + 1 < h:
				var dwn: Color = img.get_pixel(x, y + 1)
				if dwn.a * 255.0 >= OPAQUE_ALPHA and absf(luma - _luma(dwn)) > 0.12:
					edges += 1
	var occ: float = float(opaque) / float(maxi(1, w * h))
	return {
		"unique_colors": unique.size(),
		"luminance_min": luma_min if opaque > 0 else 0.0,
		"luminance_max": luma_max if opaque > 0 else 0.0,
		"luminance_range": (luma_max - luma_min) if opaque > 0 else 0.0,
		"mean_saturation": (sat_sum / float(opaque)) if opaque > 0 else 0.0,
		"alpha_occupancy": occ,
		"edge_density": (float(edges) / float(opaque)) if opaque > 0 else 0.0,
		"very_dark_pct": (float(dark) / float(opaque)) if opaque > 0 else 0.0,
		"very_bright_pct": (float(bright) / float(opaque)) if opaque > 0 else 0.0,
		"opaque_pixels": opaque
	}


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


func _write_calibration_matrix_board(matrix: Array, dest: String) -> String:
	var cam_order := ["CAM_A", "CAM_B", "CAM_C"]
	var pose_order := ["POSE_1", "POSE_2", "POSE_3"]
	var lookup := {}
	for item_value in matrix:
		var item: Dictionary = item_value
		lookup["%s|%s" % [str(item.get("camera_id", "")), str(item.get("pose_id", ""))]] = item
	var inspect := 256
	var gap := 16
	var margin := 24
	var label_h := 22
	var cells: Array = []
	var max_p96_w := 96
	var max_p80_w := 80
	var max_p64_w := 64
	var max_scale_h := inspect
	for r in 3:
		for c in 3:
			var key: String = "%s|%s" % [cam_order[r], pose_order[c]]
			if not lookup.has(key):
				return "missing calibration cell %s" % key
			var item: Dictionary = lookup[key]
			var grit: Image = item["grit"]
			var inspect_copy: Image = grit.duplicate()
			inspect_copy.resize(inspect, inspect, Image.INTERPOLATE_NEAREST)
			var p96: Image = _presentation_at_height(grit, 96)
			var p80: Image = _presentation_at_height(grit, 80)
			var p64: Image = _presentation_at_height(grit, 64)
			max_p96_w = maxi(max_p96_w, p96.get_width())
			max_p80_w = maxi(max_p80_w, p80.get_width())
			max_p64_w = maxi(max_p64_w, p64.get_width())
			max_scale_h = maxi(max_scale_h, 10 + maxi(p96.get_height(), maxi(p80.get_height(), p64.get_height())))
			cells.append({
				"item": item,
				"inspect": inspect_copy,
				"p96": p96,
				"p80": p80,
				"p64": p64
			})
	var cell_w: int = inspect + gap + max_p96_w + gap + max_p80_w + gap + max_p64_w
	var cell_h: int = label_h + maxi(inspect, max_scale_h)
	var w: int = margin * 2 + 3 * cell_w + 2 * 28
	var h: int = margin * 2 + 28 + 3 * cell_h + 2 * 24
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.12, 0.12, 0.14, 1.0))
	_draw_text(board, margin, margin, "CAMERA POSE CALIBRATION  GROUNDED GRIT  SE  NON-CANON  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in cells.size():
		var col: int = i % 3
		var row: int = int(i / 3)
		var packed: Dictionary = cells[i]
		var cell_item: Dictionary = packed["item"]
		var ox: int = margin + col * (cell_w + 28)
		var oy: int = margin + 22 + row * (cell_h + 24)
		var label: String = "%s %s %s  %d DEG" % [
			str(cell_item.get("camera_id", "")),
			str(cell_item.get("pose_id", "")),
			str(cell_item.get("pose_label", "")).replace("_", " "),
			int(cell_item.get("elevation_deg", 0))
		]
		_draw_text(board, ox, oy, label, Color(0.78, 0.78, 0.74, 1.0))
		var iy: int = oy + label_h
		var inspect_img: Image = packed["inspect"]
		_draw_checker(board, ox, iy, inspect, inspect)
		_blend_sprite(board, inspect_img, ox, iy)
		var s96: Image = packed["p96"]
		var s80: Image = packed["p80"]
		var s64: Image = packed["p64"]
		var sx: int = ox + inspect + gap
		_draw_text(board, sx, iy, "96", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s96.get_width(), s96.get_height())
		_blend_sprite(board, s96, sx, iy + 10)
		sx += max_p96_w + gap
		_draw_text(board, sx, iy, "80", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s80.get_width(), s80.get_height())
		_blend_sprite(board, s80, sx, iy + 10)
		sx += max_p80_w + gap
		_draw_text(board, sx, iy, "64", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s64.get_width(), s64.get_height())
		_blend_sprite(board, s64, sx, iy + 10)
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save calibration matrix board"
	return ""


func _write_calibration_actual_scale_board(matrix: Array, dest: String) -> String:
	var cam_order := ["CAM_A", "CAM_B", "CAM_C"]
	var pose_order := ["POSE_1", "POSE_2", "POSE_3"]
	var lookup := {}
	for item_value in matrix:
		var item: Dictionary = item_value
		lookup["%s|%s" % [str(item.get("camera_id", "")), str(item.get("pose_id", ""))]] = item
	var gap := 48
	var margin := 32
	var label_h := 18
	var samples: Array = []
	var max_w := 80
	var max_h := 80
	for r in 3:
		for c in 3:
			var key: String = "%s|%s" % [cam_order[r], pose_order[c]]
			if not lookup.has(key):
				return "missing calibration cell %s" % key
			var item: Dictionary = lookup[key]
			var grit: Image = item["grit"]
			var p80: Image = _presentation_at_height(grit, 80)
			samples.append({
				"img": p80,
				"label": "%s %s" % [cam_order[r], pose_order[c]]
			})
			max_w = maxi(max_w, p80.get_width())
			max_h = maxi(max_h, p80.get_height())
	var w: int = margin * 2 + 3 * max_w + 2 * gap
	var h: int = margin * 2 + 24 + 3 * (label_h + max_h) + 2 * gap
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.11, 0.11, 0.13, 1.0))
	_draw_text(board, margin, margin, "ACTUAL SCALE 80 PX  ALL 9  GROUNDED GRIT  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in samples.size():
		var col: int = i % 3
		var row: int = int(i / 3)
		var ox: int = margin + col * (max_w + gap)
		var oy: int = margin + 22 + row * (label_h + max_h + gap)
		var sample: Dictionary = samples[i]
		_draw_text(board, ox, oy, str(sample["label"]), Color(0.74, 0.74, 0.70, 1.0))
		var img: Image = sample["img"]
		_draw_checker(board, ox, oy + label_h, img.get_width(), img.get_height())
		_blend_sprite(board, img, ox, oy + label_h)
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save actual-scale calibration board"
	return ""


func _write_silhouette_board(matrix: Array, dest: String) -> String:
	var pose_order := ["HYBRID_A", "HYBRID_B", "HYBRID_C"]
	var lookup := {}
	for item_value in matrix:
		var item: Dictionary = item_value
		lookup[str(item.get("pose_id", ""))] = item
	var inspect := 256
	var gap := 16
	var margin := 24
	var label_h := 22
	var cells: Array = []
	var max_p96_w := 96
	var max_p80_w := 80
	var max_p64_w := 64
	var max_scale_h := inspect
	for pose_id in pose_order:
		if not lookup.has(pose_id):
			return "missing silhouette cell %s" % pose_id
		var item: Dictionary = lookup[pose_id]
		var grit: Image = item["grit"]
		var inspect_copy: Image = grit.duplicate()
		inspect_copy.resize(inspect, inspect, Image.INTERPOLATE_NEAREST)
		var p96: Image = _presentation_at_height(grit, 96)
		var p80: Image = _presentation_at_height(grit, 80)
		var p64: Image = _presentation_at_height(grit, 64)
		max_p96_w = maxi(max_p96_w, p96.get_width())
		max_p80_w = maxi(max_p80_w, p80.get_width())
		max_p64_w = maxi(max_p64_w, p64.get_width())
		max_scale_h = maxi(max_scale_h, 10 + maxi(p96.get_height(), maxi(p80.get_height(), p64.get_height())))
		cells.append({
			"item": item,
			"inspect": inspect_copy,
			"p96": p96,
			"p80": p80,
			"p64": p64
		})
	var cell_w: int = inspect + gap + max_p96_w + gap + max_p80_w + gap + max_p64_w
	var cell_h: int = label_h + maxi(inspect, max_scale_h)
	var w: int = margin * 2 + 3 * cell_w + 2 * 28
	var h: int = margin * 2 + 28 + cell_h
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.12, 0.12, 0.14, 1.0))
	_draw_text(board, margin, margin, "RIFLE SILHOUETTE  GROUNDED GRIT  SE  56 DEG  NON-CANON  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in cells.size():
		var packed: Dictionary = cells[i]
		var cell_item: Dictionary = packed["item"]
		var ox: int = margin + i * (cell_w + 28)
		var oy: int = margin + 22
		var label: String = "%s %s" % [
			str(cell_item.get("pose_id", "")),
			str(cell_item.get("pose_label", "")).replace("_", " ")
		]
		_draw_text(board, ox, oy, label, Color(0.78, 0.78, 0.74, 1.0))
		var iy: int = oy + label_h
		_draw_checker(board, ox, iy, inspect, inspect)
		_blend_sprite(board, packed["inspect"], ox, iy)
		var s96: Image = packed["p96"]
		var s80: Image = packed["p80"]
		var s64: Image = packed["p64"]
		var sx: int = ox + inspect + gap
		_draw_text(board, sx, iy, "96", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s96.get_width(), s96.get_height())
		_blend_sprite(board, s96, sx, iy + 10)
		sx += max_p96_w + gap
		_draw_text(board, sx, iy, "80", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s80.get_width(), s80.get_height())
		_blend_sprite(board, s80, sx, iy + 10)
		sx += max_p80_w + gap
		_draw_text(board, sx, iy, "64", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s64.get_width(), s64.get_height())
		_blend_sprite(board, s64, sx, iy + 10)
	var save_err: Error = board.save_png(dest)
	if save_err != OK:
		return "failed to save rifle silhouette board"
	return ""


func _write_silhouette_actual_scale_board(matrix: Array, dest: String) -> String:
	var pose_order := ["HYBRID_A", "HYBRID_B", "HYBRID_C"]
	var lookup := {}
	for item_value in matrix:
		var item: Dictionary = item_value
		lookup[str(item.get("pose_id", ""))] = item
	var gap := 56
	var margin := 36
	var label_h := 18
	var samples: Array = []
	var max_w := 80
	var max_h80 := 80
	var max_h64 := 64
	for pose_id in pose_order:
		if not lookup.has(pose_id):
			return "missing silhouette cell %s" % pose_id
		var item: Dictionary = lookup[pose_id]
		var grit: Image = item["grit"]
		var p80: Image = _presentation_at_height(grit, 80)
		var p64: Image = _presentation_at_height(grit, 64)
		samples.append({
			"pose_id": pose_id,
			"p80": p80,
			"p64": p64
		})
		max_w = maxi(max_w, maxi(p80.get_width(), p64.get_width()))
		max_h80 = maxi(max_h80, p80.get_height())
		max_h64 = maxi(max_h64, p64.get_height())
	var w: int = margin * 2 + 3 * max_w + 2 * gap
	var h: int = margin * 2 + 24 + (label_h + max_h80) + gap + (label_h + max_h64)
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.11, 0.11, 0.13, 1.0))
	_draw_text(board, margin, margin, "ACTUAL SCALE  80 AND 64 PX  HYBRID A B C  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in samples.size():
		var sample: Dictionary = samples[i]
		var ox: int = margin + i * (max_w + gap)
		var oy80: int = margin + 22
		_draw_text(board, ox, oy80, "%s 80" % str(sample["pose_id"]), Color(0.74, 0.74, 0.70, 1.0))
		var img80: Image = sample["p80"]
		_draw_checker(board, ox, oy80 + label_h, img80.get_width(), img80.get_height())
		_blend_sprite(board, img80, ox, oy80 + label_h)
		var oy64: int = oy80 + label_h + max_h80 + gap
		_draw_text(board, ox, oy64, "%s 64" % str(sample["pose_id"]), Color(0.74, 0.74, 0.70, 1.0))
		var img64: Image = sample["p64"]
		_draw_checker(board, ox, oy64 + label_h, img64.get_width(), img64.get_height())
		_blend_sprite(board, img64, ox, oy64 + label_h)
	var save_err: Error = board.save_png(dest)
	if save_err != OK:
		return "failed to save rifle silhouette actual-scale board"
	return ""


func _write_style_matrix_board(matrix: Array, dest: String) -> String:
	var source_order := ["SOURCE_0", "SOURCE_1", "SOURCE_2"]
	var post_order := ["POST_0", "POST_1", "POST_2"]
	var labels := {
		"SOURCE_0": "CONTROL",
		"SOURCE_1": "MATTE MUTED",
		"SOURCE_2": "SHAPED GRIT",
		"POST_0": "CLEAN",
		"POST_1": "SHAPE COMPRESSED",
		"POST_2": "DIGITIZED STRUCTURE"
	}
	var lookup := {}
	for item_value in matrix:
		var item: Dictionary = item_value
		lookup["%s|%s" % [str(item.get("source_id", "")), str(item.get("post_id", ""))]] = item
	var inspect := 256
	var gap := 16
	var margin := 24
	var label_h := 22
	var cells: Array = []
	var max_p96_w := 96
	var max_p80_w := 80
	var max_p64_w := 64
	var max_scale_h := inspect
	for r in 3:
		for c in 3:
			var key: String = "%s|%s" % [source_order[r], post_order[c]]
			if not lookup.has(key):
				return "missing style cell %s" % key
			var item: Dictionary = lookup[key]
			var processed: Image = item["processed"]
			var inspect_copy: Image = processed.duplicate()
			inspect_copy.resize(inspect, inspect, Image.INTERPOLATE_NEAREST)
			var p96: Image = _presentation_at_height(processed, 96)
			var p80: Image = _presentation_at_height(processed, 80)
			var p64: Image = _presentation_at_height(processed, 64)
			max_p96_w = maxi(max_p96_w, p96.get_width())
			max_p80_w = maxi(max_p80_w, p80.get_width())
			max_p64_w = maxi(max_p64_w, p64.get_width())
			max_scale_h = maxi(max_scale_h, 10 + maxi(p96.get_height(), maxi(p80.get_height(), p64.get_height())))
			cells.append({
				"item": item,
				"inspect": inspect_copy,
				"p96": p96,
				"p80": p80,
				"p64": p64
			})
	var cell_w: int = inspect + gap + max_p96_w + gap + max_p80_w + gap + max_p64_w
	var cell_h: int = label_h + maxi(inspect, max_scale_h)
	var w: int = margin * 2 + 3 * cell_w + 2 * 28
	var h: int = margin * 2 + 28 + 3 * cell_h + 2 * 24
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.12, 0.12, 0.14, 1.0))
	_draw_text(board, margin, margin, "STYLE CONVERSION  3X3  SE  56 DEG  HYBRID B  NON-CANON  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in cells.size():
		var col: int = i % 3
		var row: int = int(i / 3)
		var packed: Dictionary = cells[i]
		var cell_item: Dictionary = packed["item"]
		var ox: int = margin + col * (cell_w + 28)
		var oy: int = margin + 22 + row * (cell_h + 24)
		var sid: String = str(cell_item.get("source_id", ""))
		var pid: String = str(cell_item.get("post_id", ""))
		var label: String = "%s %s  %s %s" % [sid, str(labels.get(sid, "")), pid, str(labels.get(pid, ""))]
		_draw_text(board, ox, oy, label, Color(0.78, 0.78, 0.74, 1.0))
		var iy: int = oy + label_h
		_draw_checker(board, ox, iy, inspect, inspect)
		_blend_sprite(board, packed["inspect"], ox, iy)
		var s96: Image = packed["p96"]
		var s80: Image = packed["p80"]
		var s64: Image = packed["p64"]
		var sx: int = ox + inspect + gap
		_draw_text(board, sx, iy, "96", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s96.get_width(), s96.get_height())
		_blend_sprite(board, s96, sx, iy + 10)
		sx += max_p96_w + gap
		_draw_text(board, sx, iy, "80", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s80.get_width(), s80.get_height())
		_blend_sprite(board, s80, sx, iy + 10)
		sx += max_p80_w + gap
		_draw_text(board, sx, iy, "64", Color(0.65, 0.65, 0.62, 1.0))
		_draw_checker(board, sx, iy + 10, s64.get_width(), s64.get_height())
		_blend_sprite(board, s64, sx, iy + 10)
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save style conversion matrix board"
	return ""


func _write_style_actual_scale_board(matrix: Array, dest: String) -> String:
	var source_order := ["SOURCE_0", "SOURCE_1", "SOURCE_2"]
	var post_order := ["POST_0", "POST_1", "POST_2"]
	var lookup := {}
	for item_value in matrix:
		var item: Dictionary = item_value
		lookup["%s|%s" % [str(item.get("source_id", "")), str(item.get("post_id", ""))]] = item
	var gap := 48
	var margin := 32
	var label_h := 18
	var samples: Array = []
	var max_w := 80
	var max_h80 := 80
	var max_h64 := 64
	for r in 3:
		for c in 3:
			var key: String = "%s|%s" % [source_order[r], post_order[c]]
			if not lookup.has(key):
				return "missing style cell %s" % key
			var item: Dictionary = lookup[key]
			var processed: Image = item["processed"]
			var p80: Image = _presentation_at_height(processed, 80)
			var p64: Image = _presentation_at_height(processed, 64)
			samples.append({
				"label": "%s %s" % [source_order[r], post_order[c]],
				"p80": p80,
				"p64": p64
			})
			max_w = maxi(max_w, maxi(p80.get_width(), p64.get_width()))
			max_h80 = maxi(max_h80, p80.get_height())
			max_h64 = maxi(max_h64, p64.get_height())
	var w: int = margin * 2 + 3 * max_w + 2 * gap
	var h: int = margin * 2 + 24 + 3 * ((label_h + max_h80) + 12 + (label_h + max_h64)) + 2 * gap
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.11, 0.11, 0.13, 1.0))
	_draw_text(board, margin, margin, "ACTUAL SCALE  80 AND 64 PX  9 STYLE CANDIDATES  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in samples.size():
		var col: int = i % 3
		var row: int = int(i / 3)
		var sample: Dictionary = samples[i]
		var ox: int = margin + col * (max_w + gap)
		var block_h: int = (label_h + max_h80) + 12 + (label_h + max_h64)
		var oy: int = margin + 22 + row * (block_h + gap)
		_draw_text(board, ox, oy, "%s 80" % str(sample["label"]), Color(0.74, 0.74, 0.70, 1.0))
		var img80: Image = sample["p80"]
		_draw_checker(board, ox, oy + label_h, img80.get_width(), img80.get_height())
		_blend_sprite(board, img80, ox, oy + label_h)
		var oy64: int = oy + label_h + max_h80 + 12
		_draw_text(board, ox, oy64, "%s 64" % str(sample["label"]), Color(0.74, 0.74, 0.70, 1.0))
		var img64: Image = sample["p64"]
		_draw_checker(board, ox, oy64 + label_h, img64.get_width(), img64.get_height())
		_blend_sprite(board, img64, ox, oy64 + label_h)
	var save_err: Error = board.save_png(dest)
	if save_err != OK:
		return "failed to save style actual-scale board"
	return ""


func _write_style_source_board(sources: Array, dest: String) -> String:
	var inspect := 384
	var gap := 28
	var margin := 24
	var label_h := 20
	var w: int = margin * 2 + 3 * inspect + 2 * gap
	var h: int = margin * 2 + 28 + label_h + inspect
	var board := Image.create(w, h, false, Image.FORMAT_RGBA8)
	board.fill(Color(0.12, 0.12, 0.14, 1.0))
	_draw_text(board, margin, margin, "DAZ SOURCE PROFILES  512  SE  56 DEG  HYBRID B  NO WINNER", Color(0.88, 0.88, 0.84, 1.0))
	for i in sources.size():
		var item: Dictionary = sources[i]
		var img: Image = item["image"]
		var copy: Image = img.duplicate()
		copy.resize(inspect, inspect, Image.INTERPOLATE_NEAREST)
		var ox: int = margin + i * (inspect + gap)
		var oy: int = margin + 22
		_draw_text(board, ox, oy, "%s %s" % [str(item.get("id", "")), str(item.get("label", ""))], Color(0.78, 0.78, 0.74, 1.0))
		_draw_checker(board, ox, oy + label_h, inspect, inspect)
		_blend_sprite(board, copy, ox, oy + label_h)
	var err: Error = board.save_png(dest)
	if err != OK:
		return "failed to save style source comparison board"
	return ""


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
			var px: int = ox + x
			var py: int = oy + y
			if px < 0 or py < 0 or px >= board.get_width() or py >= board.get_height():
				continue
			var use_a: bool = ((int(x / size) + int(y / size)) % 2) == 0
			board.set_pixel(px, py, a if use_a else b)


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
		"+": ["00000", "00100", "00100", "11111", "00100", "00100", "00000"],
		"_": ["00000", "00000", "00000", "00000", "00000", "00000", "11111"]
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
