module main

import obstacle
import tests_helpers

fn test_block_width_0_returns_an_error() {
	test_function := get_test_function(0, 1)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.block_width_smaller_than_zero_error)
}

fn test_block_width_minus_one_returns_an_error() {
	test_function := get_test_function(-1, 1)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.block_width_smaller_than_zero_error)
}

fn test_screen_width_0_returns_an_error() {
	test_function := get_test_function(1, 0)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.screen_width_smaller_than_zero_error)
}

fn test_screen_width_minus_one_returns_an_error() {
	test_function := get_test_function(1, -1)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.screen_width_smaller_than_zero_error)
}

fn test_get_x_position_calculation_function_return_functions_produces_expected_results_for_left_orientation() {
	x_calculation_function := get_test_position_calculation_function(obstacle.Orientation.left)!

	assert x_calculation_function(0) == 0
	assert x_calculation_function(1) == 1
}

fn test_get_x_position_calculation_function_return_functions_produces_expected_results_for_right_orientation() {
	x_calculation_function := get_test_position_calculation_function(obstacle.Orientation.right)!

	assert x_calculation_function(0) == 9
	assert x_calculation_function(1) == 8
}

fn get_test_function(block_width int, screen_width int) fn () !fn (int) int {
	return fn [block_width, screen_width] () !fn (int) int {
		return get_x_position_calculation_function(obstacle.Orientation.left, block_width,
			screen_width)
	}
}

fn get_test_position_calculation_function(obstacle_side obstacle.Orientation) !fn (int) int {
	return get_x_position_calculation_function(obstacle_side, 1, 10)!
}

fn get_x_position_calculation_function(obstacle_side obstacle.Orientation, block_width int, screen_width int) !fn (int) int {
	return obstacle.get_x_position_calculation_function(obstacle_side, block_width, screen_width)
}
