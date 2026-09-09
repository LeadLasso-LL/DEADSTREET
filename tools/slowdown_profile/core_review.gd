extends SceneTree
func _initialize() -> void:
	var result = load("res://core/core_validation.gd").run()
	var failed: Array[String] = []
	for key in result["checks"]:
		if result["checks"][key] != true: failed.append(str(key))
	var report = {"passed":result["passed"],"count":result["checks"].size(),"failed":failed}
	FileAccess.open("res://tools/slowdown_profile/core_result.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("CORE_REVIEW ",JSON.stringify(report))
	quit(0 if result["passed"] else 1)
