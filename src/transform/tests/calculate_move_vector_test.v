module main

import transform

fn test_calculate_move_vector_with_0_speed_returns_an_error() {
	test_function := get_test_function_with_normalized_direction(0, 1)
	expect_error_from_test_function(test_function, transform.speed_is_zero_error)
}

fn test_calculate_move_vector_with_negative_speed_returns_an_error() {
	test_function := get_test_function_with_normalized_direction(-1, 1)
	expect_error_from_test_function(test_function, transform.negative_speed_error)
}

fn test_calculate_move_vector_with_0_delta_time_returns_an_error() {
	test_function := get_test_function_with_normalized_direction(1, 0)
	expect_error_from_test_function(test_function, transform.delta_time_smaller_than_zero_error)
}

fn test_calculate_move_vector_with_negative_delta_time_returns_an_error() {
	test_function := get_test_function_with_normalized_direction(1, -1)
	expect_error_from_test_function(test_function, transform.delta_time_smaller_than_zero_error)
}

fn test_calculate_move_vector_with_unnormalized_direction_returns_an_error() {
	test_function := get_test_function(transform.Vector{5, 10}, 1, 1)
	expect_error_from_test_function(test_function, transform.direction_not_normalized)
}

fn get_test_function_with_normalized_direction(speed f64, delta_time f64) fn () !transform.Vector {
	return get_test_function(get_normalized_vector(), speed, delta_time)
}

fn get_test_function(direction transform.Vector, speed f64, delta_time f64) fn () !transform.Vector {
	return fn [direction, speed, delta_time] () !transform.Vector {
		return transform.calculate_move_vector(direction, speed, delta_time)
	}
}

fn get_normalized_vector() transform.Vector {
	return transform.Vector{0, 1}
}

fn expect_error_from_test_function(test_function fn () !transform.Vector, expected_error string) {
	test_function() or {
		assert err.msg() == expected_error
		return
	}

	assert false
}
