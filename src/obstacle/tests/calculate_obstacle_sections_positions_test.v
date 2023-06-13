module main

import obstacle
import transform
import tests_helpers

fn test_sections_count_0_returns_an_error() {
	test_function := get_test_function(0, obstacle.Orientation.left, 1, 1)

	tests_helpers.expect_error_from_test_function(test_function, obstacle.sections_count_smaller_than_zero_error)
}

fn test_sections_count_minus_one_returns_an_error() {
	test_function := get_test_function(-1, obstacle.Orientation.left, 1, 1)

	tests_helpers.expect_error_from_test_function(test_function, obstacle.sections_count_smaller_than_zero_error)
}

fn test_section_width_1_and_section_count_1_returns_expected_positions() {
	assert calculate_obstacle_sections_positions(1, obstacle.Orientation.left, 1, 1)! == [
		transform.Position{},
	]
}

fn test_section_width_1_and_section_count_2_returns_expected_positions() {
	assert calculate_obstacle_sections_positions(2, obstacle.Orientation.left, 1, 1)! == [
		transform.Position{},
		transform.Position{
			x: 1.0
		},
	]
}

fn test_section_width_10_and_section_count_5_returns_expected_positions() {
	assert calculate_obstacle_sections_positions(5, obstacle.Orientation.left, 10, 1)! == [
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

fn get_test_function(sections_count int, obstacle_side obstacle.Orientation, section_width int, screen_width int) fn () ![]transform.Position {
	return fn [sections_count, obstacle_side, section_width, screen_width] () ![]transform.Position {
		return calculate_obstacle_sections_positions(sections_count, obstacle_side, section_width,
			screen_width)
	}
}

fn calculate_obstacle_sections_positions(sections_count int, obstacle_side obstacle.Orientation, section_width int, screen_width int) ![]transform.Position {
	return obstacle.calculate_obstacle_sections_positions(sections_count, obstacle_side,
		section_width, screen_width)
}
