extends TestSuite


func test_small_numbers_are_whole() -> void:
	assert_eq(NumberFormat.short(0.0), "0")
	assert_eq(NumberFormat.short(999.9), "999")


func test_suffixes_keep_three_significant_digits() -> void:
	assert_eq(NumberFormat.short(1234.0), "1.23K")
	assert_eq(NumberFormat.short(45_600_000.0), "45.6M")
	assert_eq(NumberFormat.short(789e9), "789B")
	assert_eq(NumberFormat.short(2.0e15), "2.00Qa")


func test_rounding_rolls_over_to_next_suffix() -> void:
	assert_eq(NumberFormat.short(999_999.0), "1.00M")


func test_yen_prefix() -> void:
	assert_eq(NumberFormat.yen(500e6), "¥500M")
