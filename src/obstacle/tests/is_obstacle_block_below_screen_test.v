module main

import obstacle
import transform
import tests_helpers

fn test_check_is_obstacle_block_below_screen_with_0_screen_height_returns_an_error() {
	test_function := get_test_function(transform.Position{}, 0)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.screen_height_smaller_than_zero_error)
}

fn test_check_is_obstacle_block_below_screen_with_negative_screen_height_returns_an_error() {
	test_function := get_test_function(transform.Position{}, -1)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.screen_height_smaller_than_zero_error)
}

fn test_check_is_obstacle_block_below_screen_returns_expected_value_for_block_that_below_screen() {
	assert is_obstacle_block_below_screen(transform.Position{ y: 11 }, 10)! == true
}

fn test_check_is_obstacle_block_below_screen_returns_expected_value_for_block_that_on_the_edge_of_screen() {
	assert is_obstacle_block_below_screen(transform.Position{ y: 10 }, 10)! == true
}

fn test_check_is_obstacle_block_below_screen_returns_expected_value_for_block_that_is_not_below_screen() {
	assert is_obstacle_block_below_screen(transform.Position{ y: 9 }, 10)! == false
}

fn get_test_function(position transform.Position, screen_height int) fn () !bool {
	return fn [position, screen_height] () !bool {
		return is_obstacle_block_below_screen(position, screen_height)
	}
}

fn is_obstacle_block_below_screen(position transform.Position, screen_height int) !bool {
	return obstacle.is_obstacle_block_below_screen(position, screen_height)
}
