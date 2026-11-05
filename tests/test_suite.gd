class_name TestSuite
extends RefCounted
## Base class for tests: methods named test_* are run by tests/run_tests.gd.

var failures: Array[String] = []


func assert_true(condition: bool, message: String = "") -> void:
	if not condition:
		failures.append("expected true. " + message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		failures.append("expected %s, got %s. %s" % [expected, actual, message])


## Relative tolerance compare for floats that may be huge.
func assert_near(actual: float, expected: float, rel: float = 1e-9, message: String = "") -> void:
	var scale: float = maxf(1.0, maxf(absf(actual), absf(expected)))
	if absf(actual - expected) > rel * scale:
		failures.append("expected %s, got %s. %s" % [expected, actual, message])
