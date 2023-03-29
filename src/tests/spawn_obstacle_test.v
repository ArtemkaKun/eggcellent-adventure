module main

import obstacle
import world
import transform

fn test_spawn_obstacle_works_with_empty_model() {
	empty_model := world.WorldModel{}
	new_model := obstacle.spawn_obstacle(empty_model, 3, 1, 1, 2)!

	assert new_model.obstacles == [
		[
			transform.Position{0, -1},
			transform.Position{1, -1},
		],
	]
}

fn test_spawn_obstacle_works_with_non_empty_model() {
	non_empty_model := world.WorldModel{
		obstacles: [
			[
				transform.Position{0, 0},
			],
		]
	}

	new_model := obstacle.spawn_obstacle(non_empty_model, 3, 1, 1, 2)!

	assert new_model.obstacles == [
		[
			transform.Position{0, 0},
		],
		[
			transform.Position{0, -1},
			transform.Position{1, -1},
		],
	]
}

fn test_spawn_obstacle_blocks_count_in_expected_range() {
	min_expected_blocks := 2
	max_expected_blocks := 4
	empty_model := world.WorldModel{}

	for _ in 0 .. 1000 {
		new_model := obstacle.spawn_obstacle(empty_model, 5, 1, 1, 2)!

		assert new_model.obstacles[0].len >= min_expected_blocks
		assert new_model.obstacles[0].len <= max_expected_blocks
	}
}
