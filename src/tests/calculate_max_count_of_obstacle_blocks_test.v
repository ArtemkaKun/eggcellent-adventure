module main

import obstacle

fn test_screen_width_0_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_blocks(0, 0) or {
		assert err.msg() == 'screen_width must be greater than 0!'
		return
	}

	assert false
}

fn test_screen_width_minus_one_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_blocks(-1, 0) or {
		assert err.msg() == 'screen_width must be greater than 0!'
		return
	}

	assert false
}

fn test_block_width_0_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_blocks(1, 0) or {
		assert err.msg() == 'block_width must be greater than 0!'
		return
	}

	assert false
}

fn test_block_width_minus_one_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_blocks(1, -1) or {
		assert err.msg() == 'block_width must be greater than 0!'
		return
	}

	assert false
}

fn test_screen_width_smaller_than_block_width_returns_an_error() {
	obstacle.calculate_max_count_of_obstacle_blocks(1, 2) or {
		assert err.msg() == 'screen_width must be greater or equal than block_width!'
		return
	}

	assert false
}

fn test_screen_width_equals_block_width_returns_1() {
	assert obstacle.calculate_max_count_of_obstacle_blocks(1, 1)! == 1
}

fn test_screen_width_2_block_width_1_returns_2() {
	assert obstacle.calculate_max_count_of_obstacle_blocks(2, 1)! == 2
}

fn test_screen_width_15_block_width_10_returns_1() {
	assert obstacle.calculate_max_count_of_obstacle_blocks(15, 10)! == 1
}
