module main

import obstacle
import transform

fn test_block_width_0_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(0, 0) or {
		assert err.msg() == obstacle.block_width_smaller_than_zero_error
		return
	}

	assert false
}

fn test_block_width_minus_one_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(-1, 0) or {
		assert err.msg() == obstacle.block_width_smaller_than_zero_error
		return
	}

	assert false
}

fn test_blocks_count_0_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(1, 0) or {
		assert err.msg() == obstacle.blocks_count_smaller_than_zero_error
		return
	}

	assert false
}

fn test_blocks_count_minus_one_returns_an_error() {
	obstacle.calculate_obstacle_blocks_positions(1, -1) or {
		assert err.msg() == obstacle.blocks_count_smaller_than_zero_error
		return
	}

	assert false
}

fn test_block_width_1_and_block_count_1_returns_expected_positions() {
	assert obstacle.calculate_obstacle_blocks_positions(1, 1)! == [
		transform.Position{},
	]
}

fn test_block_width_1_and_block_count_2_returns_expected_positions() {
	assert obstacle.calculate_obstacle_blocks_positions(1, 2)! == [
		transform.Position{},
		transform.Position{
			x: 1.0
		},
	]
}

fn test_block_width_10_and_block_count_5_returns_expected_positions() {
	assert obstacle.calculate_obstacle_blocks_positions(10, 5)! == [
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
