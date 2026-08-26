extends Node


func _ready() -> void:
	var result := CoreValidation.run()
	var checks: Dictionary = result["checks"]
	if result["passed"] == true:
		print("DEAD STREET CORE VALIDATION: PASS")
	else:
		print("DEAD STREET CORE VALIDATION: FAIL")
		push_error("DEAD STREET CORE VALIDATION: FAIL checks=%s" % str(checks))
	print(checks)
