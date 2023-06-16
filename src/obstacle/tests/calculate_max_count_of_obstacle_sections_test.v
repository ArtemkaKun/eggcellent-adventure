module main

import obstacle

fn test_screen_width_0_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_sections(0, 0) or {
		assert err.msg() == obstacle.screen_width_smaller_than_zero_error
		return
	}

	assert false
}

fn test_screen_width_minus_one_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_sections(-1, 0) or {
		assert err.msg() == obstacle.screen_width_smaller_than_zero_error
		return
	}

	assert false
}

fn test_section_width_0_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_sections(1, 0) or {
		assert err.msg() == obstacle.section_width_smaller_than_zero_error
		return
	}

	assert false
}

fn test_section_width_minus_one_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_sections(1, -1) or {
		assert err.msg() == obstacle.section_width_smaller_than_zero_error
		return
	}

	assert false
}

fn test_screen_width_smaller_than_section_width_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_sections(1, 2) or {
		assert err.msg() == obstacle.screen_width_smaller_than_section_width_error
		return
	}

	assert false
}

fn test_screen_width_equals_section_width_returns_1() {
	assert obstacle.calculate_max_count_of_obstacle_sections(1, 1)! == 1
}

fn test_screen_width_2_section_width_1_returns_2() {
	assert obstacle.calculate_max_count_of_obstacle_sections(2, 1)! == 2
}

fn test_screen_width_15_section_width_10_returns_1() {
	assert obstacle.calculate_max_count_of_obstacle_sections(15, 10)! == 1
}
