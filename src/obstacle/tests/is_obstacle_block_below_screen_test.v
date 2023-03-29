module main

import obstacle
import transform

fn test_check_is_obstacle_block_below_screen_with_0_screen_height_returns_an_error() {
	obstacle.is_obstacle_block_below_screen(transform.Position{}, 0) or {
		assert err.msg() == obstacle.screen_height_smaller_than_zero_error
		return
	}

	assert false
}

fn test_check_is_obstacle_block_below_screen_with_negative_screen_height_returns_an_error() {
	obstacle.is_obstacle_block_below_screen(transform.Position{}, -1) or {
		assert err.msg() == obstacle.screen_height_smaller_than_zero_error
		return
	}

	assert false
}

fn test_check_is_obstacle_block_below_screen_returns_expected_value_for_block_that_below_screen() {
	assert obstacle.is_obstacle_block_below_screen(transform.Position{ y: 11 }, 10)! == true
}

fn test_check_is_obstacle_block_below_screen_returns_expected_value_for_block_that_on_the_edge_of_screen() {
	assert obstacle.is_obstacle_block_below_screen(transform.Position{ y: 10 }, 10)! == true
}

fn test_check_is_obstacle_block_below_screen_returns_expected_value_for_block_that_is_not_below_screen() {
	assert obstacle.is_obstacle_block_below_screen(transform.Position{ y: 9 }, 10)! == false
}
