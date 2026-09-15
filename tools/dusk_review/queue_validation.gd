extends SceneTree
func _initialize():
	var result = load("res://core/core_validation.gd").run()
	var failed = []
	for name in result["checks"]:
		if result["checks"][name] != true: failed.append(name)
	print("QUEUE_VALIDATION ",JSON.stringify({"passed":result["passed"],"count":result["checks"].size(),"failed":failed}))
	quit(0 if result["passed"] else 1)
