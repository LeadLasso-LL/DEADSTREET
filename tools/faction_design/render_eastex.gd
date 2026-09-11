extends SceneTree

func _initialize():
    var args = OS.get_cmdline_user_args()
    var base = args[0] if args.size() > 0 else "res://tools/faction_design/eastex/"
    if not base.begins_with("res://tools/faction_design/") or ".." in base:
        push_error("Invalid faction review directory")
        quit(1)
        return
    var jobs: Array = JSON.parse_string(FileAccess.get_file_as_string(base + "jobs.json"))
    var failures: Array = []
    for key: String in jobs:
        var im = Image.new()
        var err = im.load_svg_from_string(FileAccess.get_file_as_string(base + "frames/" + key + ".svg"), 2.0)
        if err != OK:
            failures.append(key + ": SVG load failed")
            continue
        im.resize(128, 128, Image.INTERPOLATE_LANCZOS)
        var rect = im.get_used_rect()
        if rect.position.x <= 0 or rect.position.y <= 0 or rect.end.x >= 128 or rect.end.y >= 128:
            failures.append(key + ": frame edge contact")
        if im.save_png(base + "frames/" + key + ".png") != OK:
            failures.append(key + ": PNG save failed")
    var report = {"frames": jobs.size(), "failures": failures}
    FileAccess.open(base + "render_validation.json", FileAccess.WRITE).store_string(JSON.stringify(report, "  "))
    print("EASTEX_REVIEW_RENDER ", JSON.stringify(report))
    quit(0 if failures.is_empty() else 1)
