module main

import obstacle
import world

fn test_block_width_0_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(0, 0) or {
		assert err.msg() == 'block_width must be greater than 0!'
		return
	}

	assert false
}

fn test_block_width_minus_one_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(-1, 0) or {
		assert err.msg() == 'block_width must be greater than 0!'
		return
	}

	assert false
}

fn test_blocks_count_0_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(1, 0) or {
		assert err.msg() == 'blocks_count must be greater than 0!'
		return
	}

	assert false
}

fn test_blocks_count_minus_one_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(1, -1) or {
		assert err.msg() == 'blocks_count must be greater than 0!'
		return
	}

	assert false
}

fn test_block_width_1_and_block_count_1_returns_expected_positions() {
	assert obstacle.calculate_obstacle_blocks_positions(1, 1)! == [
		world.Position{},
	]
}

fn test_block_width_1_and_block_count_2_returns_expected_positions() {
	assert obstacle.calculate_obstacle_blocks_positions(1, 2)! == [
		world.Position{},
		world.Position{
			x: 1.0
		},
	]
}

fn test_block_width_10_and_block_count_5_returns_expected_positions() {
	assert obstacle.calculate_obstacle_blocks_positions(10, 5)! == [
		world.Position{},
		world.Position{
			x: 10.0
		},
		world.Position{
			x: 20.0
		},
		world.Position{
			x: 30.0
		},
		world.Position{
			x: 40.0
		},
	]
}
