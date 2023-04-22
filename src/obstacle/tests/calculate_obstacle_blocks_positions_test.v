module main

import obstacle
import transform
import tests_helpers

fn test_blocks_count_0_returns_an_error() {
	test_function := get_test_function(0, obstacle.Orientation.left, 1, 1)

	tests_helpers.expect_error_from_test_function(test_function, obstacle.blocks_count_smaller_than_zero_error)
}

fn test_blocks_count_minus_one_returns_an_error() {
	test_function := get_test_function(-1, obstacle.Orientation.left, 1, 1)

	tests_helpers.expect_error_from_test_function(test_function, obstacle.blocks_count_smaller_than_zero_error)
}

fn test_block_width_1_and_block_count_1_returns_expected_positions() {
	assert calculate_obstacle_blocks_positions(1, obstacle.Orientation.left, 1, 1)! == [
		transform.Position{},
	]
}

fn test_block_width_1_and_block_count_2_returns_expected_positions() {
	assert calculate_obstacle_blocks_positions(2, obstacle.Orientation.left, 1, 1)! == [
		transform.Position{},
		transform.Position{
			x: 1.0
		},
	]
}

fn test_block_width_10_and_block_count_5_returns_expected_positions() {
	assert calculate_obstacle_blocks_positions(5, obstacle.Orientation.left, 10, 1)! == [
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

fn get_test_function(blocks_count int, obstacle_side obstacle.Orientation, block_width int, screen_width int) fn () ![]transform.Position {
	return fn [blocks_count, obstacle_side, block_width, screen_width] () ![]transform.Position {
		return calculate_obstacle_blocks_positions(blocks_count, obstacle_side, block_width,
			screen_width)
	}
}

fn calculate_obstacle_blocks_positions(blocks_count int, obstacle_side obstacle.Orientation, block_width int, screen_width int) ![]transform.Position {
	return obstacle.calculate_obstacle_blocks_positions(blocks_count, obstacle_side, block_width,
		screen_width)
}
