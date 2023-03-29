module main

import world
import obstacle
import transform

fn test_move_obstacles_works_with_empty_model() {
	empty_model := world.WorldModel{}
	new_model := obstacle.move_obstacles(empty_model, transform.Vector{0, 1}, 1.0, 1.0)!

	assert empty_model == new_model
}

fn test_move_obstacles_moves_obstacles_in_right_direction() {
	test_model := world.WorldModel{
		obstacles: [
			[
				transform.Position{0, 0},
				transform.Position{0, 1},
				transform.Position{0, 2},
			],
		]
	}

	new_model := obstacle.move_obstacles(test_model, transform.Vector{0, 1}, 1.0, 1.0)!

	assert new_model.obstacles == [
		[
			transform.Position{0, 1},
			transform.Position{0, 2},
			transform.Position{0, 3},
		],
	]
}

fn test_move_obstacles_moves_obstacles_with_right_speed() {
	test_model := world.WorldModel{
		obstacles: [
			[
				transform.Position{0, 0},
				transform.Position{0, 1},
				transform.Position{0, 2},
			],
		]
	}

	new_model := obstacle.move_obstacles(test_model, transform.Vector{0, 1}, 2.0, 1.0)!

	assert new_model.obstacles == [
		[
			transform.Position{0, 2},
			transform.Position{0, 3},
			transform.Position{0, 4},
		],
	]
}
