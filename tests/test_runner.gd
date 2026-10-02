extends Node
## Chạy mọi test trong tests/cases/ rồi thoát: mã 0 = qua hết, 1 = có test trượt.
##   godot --headless --path . res://tests/run_tests.tscn
## Chỉ chạy test có tên chứa một đoạn chữ:
##   godot --headless --path . res://tests/run_tests.tscn -- --only=hunt

const CASES_DIR: String = "res://tests/cases/"
const ONLY_ARG_PREFIX: String = "--only="


func _ready() -> void:
	# Đợi một frame để mọi autoload chạy xong _ready.
	await get_tree().process_frame
	var passed: int = 0
	var failed: int = 0
	var only: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with(ONLY_ARG_PREFIX):
			only = arg.trim_prefix(ONLY_ARG_PREFIX)
	for file: String in DirAccess.get_files_at(CASES_DIR):
		if not file.ends_with(".gd"):
			continue
		var script: GDScript = load(CASES_DIR + file)
		var test_case: TestCase = script.new()
		test_case.host = self
		for method: Dictionary in script.get_script_method_list():
			var method_name: String = method["name"]
			if not method_name.begins_with("test_") or (not only.is_empty() and not method_name.contains(only)):
				continue
			test_case.failures.clear()
			await test_case.call(method_name)
			if test_case.failures.is_empty():
				passed += 1
				print("  PASS  %s :: %s" % [file, method_name])
			else:
				failed += 1
				print("  FAIL  %s :: %s" % [file, method_name])
				for failure: String in test_case.failures:
					print("        - " + failure)
	print("KẾT QUẢ: %d qua, %d trượt" % [passed, failed])
	print("PASS" if failed == 0 else "FAIL")
	get_tree().quit(1 if failed > 0 else 0)
