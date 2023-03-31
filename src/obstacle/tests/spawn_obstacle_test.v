module main

import obstacle

fn test_spawn_obstacle_returns_error_when_screen_width_not_3_time_bigger_than_obstacle_width() {
	obstacle.spawn_random_width_obstacle(2, 1, 1, 2) or {
		assert err.msg() == obstacle.screen_width_too_small_error
		return
	}

	assert false
}

fn test_spawn_obstacle_returns_error_when_min_blocks_count_is_lower_then_2() {
	obstacle.spawn_random_width_obstacle(3, 1, 1, 1) or {
		assert err.msg() == obstacle.min_blocks_count_too_small_error
		return
	}

	assert false
}

fn test_spawn_obstacle_returns_error_when_min_blocks_count_is_the_same_as_max_blocks_count() {
	obstacle.spawn_random_width_obstacle(3, 1, 1, 3) or {
		assert err.msg() == obstacle.min_blocks_count_too_big_error
		return
	}

	assert false
}

fn test_spawn_obstacle_returns_error_when_min_blocks_count_is_bigger_than_max_blocks_count() {
	obstacle.spawn_random_width_obstacle(3, 1, 1, 4) or {
		assert err.msg() == obstacle.min_blocks_count_too_big_error
		return
	}

	assert false
}
