extends SceneTree
## Minimal headless test runner (no third-party framework).
## Usage: godot --headless --path . -s tests/run_tests.gd
## A test fails on a failed assert OR on any engine/script error while it runs,
## because Godot logs script errors and keeps going instead of throwing.

const TEST_DIR := "res://tests/"


class ErrorCounter:
	extends Logger
	var count: int = 0

	func _log_error(
		_function: String,
		_file: String,
		_line: int,
		_code: String,
		_rationale: String,
		_editor_notify: bool,
		_error_type: int,
		_script_backtraces: Array[ScriptBacktrace]
	) -> void:
		count += 1


func _initialize() -> void:
	var errors := ErrorCounter.new()
	OS.add_logger(errors)
	var total: int = 0
	var failed: int = 0
	var files: PackedStringArray = DirAccess.get_files_at(TEST_DIR)
	files.sort()
	for file: String in files:
		if not (file.begins_with("test_") and file.ends_with(".gd")) or file == "test_suite.gd":
			continue
		var script: GDScript = load(TEST_DIR + file)
		for method: Dictionary in script.get_script_method_list():
			var name: String = method["name"]
			if not name.begins_with("test_"):
				continue
			var suite: TestSuite = script.new()
			var errors_before: int = errors.count
			suite.call(name)
			total += 1
			if errors.count > errors_before:
				suite.failures.append("engine or script error (see log above)")
			if suite.failures.is_empty():
				continue
			failed += 1
			for failure: String in suite.failures:
				printerr("FAIL %s::%s: %s" % [file, name, failure])
	OS.remove_logger(errors)
	print("%d tests, %d failed" % [total, failed])
	quit(1 if failed > 0 or total == 0 else 0)
