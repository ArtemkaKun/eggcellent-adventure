module tests_helpers

fn expect_error_from_test_function[R](test_function fn () !R, expected_error string) {
	test_function() or {
		assert err.msg() == expected_error
		return
	}

	assert false
}
