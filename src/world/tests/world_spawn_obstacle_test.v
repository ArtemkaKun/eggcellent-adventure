module main

import world
import transform
import obstacle

fn test_spawn_obstacle_works_with_empty_model() {
	empty_model := world.WorldModel{}
	new_model := world.spawn_obstacle(empty_model, 0, 3, 1, 1, 2)!

	assert new_model.obstacles.len == 1
	assert new_model.obstacles[0].len == 2

	assert new_model.obstacles[0][0].position == transform.Position{0, -1}
	assert new_model.obstacles[0][1].position == transform.Position{1, -1}
}

fn test_spawn_obstacle_works_with_non_empty_model() {
	non_empty_model := world.WorldModel{
		obstacles: [
			[
				obstacle.ObstacleSection{
					position: transform.Position{0, 0}
					orientation: obstacle.Orientation.left
					image_id: 0
				},
			],
		]
	}

	new_model := world.spawn_obstacle(non_empty_model, 0, 3, 1, 1, 2)!

	assert new_model.obstacles.len == 2
	assert new_model.obstacles[0].len == 1
	assert new_model.obstacles[1].len == 2

	assert new_model.obstacles[0][0].position == transform.Position{0, 0}
	assert new_model.obstacles[1][0].position == transform.Position{0, -1}
	assert new_model.obstacles[1][1].position == transform.Position{1, -1}
}

fn test_spawn_obstacle_blocks_count_in_expected_range() {
	min_expected_blocks := 2
	max_expected_blocks := 4
	empty_model := world.WorldModel{}

	for _ in 0 .. 1000 {
		new_model := world.spawn_obstacle(empty_model, 0, 5, 1, 1, 2)!

		assert new_model.obstacles[0].len >= min_expected_blocks
		assert new_model.obstacles[0].len <= max_expected_blocks
	}
}
