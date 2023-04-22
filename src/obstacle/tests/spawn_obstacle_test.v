module main

import obstacle
import transform
import tests_helpers

fn test_spawn_obstacle_returns_error_when_screen_width_not_3_time_bigger_than_obstacle_width() {
	test_function := get_test_function(2, 1, 2, obstacle.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.screen_width_too_small_error)
}

fn test_spawn_obstacle_returns_error_when_min_blocks_count_is_lower_then_2() {
	test_function := get_test_function(3, 1, 1, obstacle.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.min_blocks_count_too_small_error)
}

fn test_spawn_obstacle_returns_error_when_min_blocks_count_is_the_same_as_max_blocks_count() {
	test_function := get_test_function(3, 1, 3, obstacle.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.min_blocks_count_too_big_error)
}

fn test_spawn_obstacle_returns_error_when_min_blocks_count_is_bigger_than_max_blocks_count() {
	test_function := get_test_function(3, 1, 4, obstacle.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.min_blocks_count_too_big_error)
}

fn get_test_function(screen_width int, obstacle_section_width int, min_blocks_count int, obstacle_side obstacle.Orientation) fn () ![]transform.Position {
	return fn [screen_width, obstacle_section_width, min_blocks_count, obstacle_side] () ![]transform.Position {
		return obstacle.spawn_random_width_obstacle(screen_width, obstacle_section_width,
			min_blocks_count, obstacle_side)
	}
}
