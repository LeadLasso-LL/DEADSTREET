extends Node

# Full checks Dictionary dump. Off unless this const is true or the process
# is launched with user arg --dump-checks.
const DUMP_ALL_CHECKS := false


func _ready() -> void:
	var result := CoreValidation.run()
	var checks: Dictionary = result["checks"]
	if result["passed"] == true:
		print("DEAD STREET CORE VALIDATION: PASS")
	else:
		var failed: Array[String] = _failed_check_names(checks)
		print("DEAD STREET CORE VALIDATION: FAIL")
		print("")
		print("FAILED CHECKS (%d):" % failed.size())
		print("")
		for check_name: String in failed:
			print("- %s" % check_name)
		push_error("DEAD STREET CORE VALIDATION: FAIL (%d checks)" % failed.size())
	if _should_dump_all_checks():
		print(checks)


func _failed_check_names(checks: Dictionary) -> Array[String]:
	var failed: Array[String] = []
	for check_name: Variant in checks:
		if checks[check_name] != true:
			failed.append(str(check_name))
	failed.sort()
	return failed


func _should_dump_all_checks() -> bool:
	if DUMP_ALL_CHECKS:
		return true
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--dump-checks":
			return true
	return false
