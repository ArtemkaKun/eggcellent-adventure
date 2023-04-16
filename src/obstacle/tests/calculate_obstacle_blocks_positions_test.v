module main

import obstacle
import transform
import tests_helpers

fn test_blocks_count_0_returns_an_error() {
	test_calculation_function := get_unit_test_position_calculation_function()!
	test_function := get_test_function(0, test_calculation_function)

	tests_helpers.expect_error_from_test_function(test_function, obstacle.blocks_count_smaller_than_zero_error)
}

fn test_blocks_count_minus_one_returns_an_error() {
	test_calculation_function := get_unit_test_position_calculation_function()!
	test_function := get_test_function(-1, test_calculation_function)

	tests_helpers.expect_error_from_test_function(test_function, obstacle.blocks_count_smaller_than_zero_error)
}

fn test_block_width_1_and_block_count_1_returns_expected_positions() {
	test_calculation_function := get_unit_test_position_calculation_function()!

	assert calculate_obstacle_blocks_positions(1, test_calculation_function)! == [
		transform.Position{},
	]
}

fn test_block_width_1_and_block_count_2_returns_expected_positions() {
	test_calculation_function := get_unit_test_position_calculation_function()!

	assert calculate_obstacle_blocks_positions(2, test_calculation_function)! == [
		transform.Position{},
		transform.Position{
			x: 1.0
		},
	]
}

fn test_block_width_10_and_block_count_5_returns_expected_positions() {
	test_calculation_function := get_test_position_calculation_function(10)!

	assert calculate_obstacle_blocks_positions(5, test_calculation_function)! == [
		transform.Position{},
		transform.Position{
			x: 10.0
		},
		transform.Position{
			x: 20.0
		},
		transform.Position{
			x: 30.0
		},
		transform.Position{
			x: 40.0
		},
	]
}

fn get_unit_test_position_calculation_function() !fn (int) int {
	return get_test_position_calculation_function(1)
}

fn get_test_position_calculation_function(block_width int) !fn (int) int {
	return get_x_position_calculation_function(obstacle.Orientation.left, block_width,
		1)
}

fn get_x_position_calculation_function(obstacle_side obstacle.Orientation, block_width int, screen_width int) !fn (int) int {
	return obstacle.get_x_position_calculation_function(obstacle_side, block_width, screen_width)
}

fn get_test_function(blocks_count int, calculate_x_position_function fn (int) int) fn () ![]transform.Position {
	return fn [blocks_count, calculate_x_position_function] () ![]transform.Position {
		return calculate_obstacle_blocks_positions(blocks_count, calculate_x_position_function)
	}
}

fn calculate_obstacle_blocks_positions(blocks_count int, calculate_x_position_function fn (int) int) ![]transform.Position {
	return obstacle.calculate_obstacle_blocks_positions(blocks_count, calculate_x_position_function)
}
