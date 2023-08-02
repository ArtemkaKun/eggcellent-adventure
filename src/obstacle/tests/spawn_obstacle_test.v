module main

import obstacle
import artemkakun.trnsfrm2d as transform
import tests_helpers
import common

fn test_spawn_obstacle_returns_error_when_min_sections_count_is_lower_then_2() {
	test_function := get_test_function(3, 1, 1, common.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.min_sections_count_too_small_error)
}

fn test_spawn_obstacle_returns_error_when_min_sections_count_is_the_same_as_max_sections_count() {
	test_function := get_test_function(3, 1, 3, common.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.min_sections_count_too_big_error)
}

fn test_spawn_obstacle_returns_error_when_min_sections_count_is_bigger_than_max_sections_count() {
	test_function := get_test_function(3, 1, 4, common.Orientation.left)
	tests_helpers.expect_error_from_test_function(test_function, obstacle.min_sections_count_too_big_error)
}

fn get_test_function(screen_width int, obstacle_section_width int, min_sections_count int, obstacle_side common.Orientation) fn () ![]transform.Position {
	return fn [screen_width, obstacle_section_width, min_sections_count, obstacle_side] () ![]transform.Position {
		return obstacle.calculate_positions_for_new_obstacle(screen_width, obstacle_section_width,
			min_sections_count, obstacle_side)
	}
}
