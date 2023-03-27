module main

import world
import transform
import obstacle

fn test_destroy_obstacle_below_screen_works_with_empty_model() {
	empty_model := world.WorldModel{}
	new_model := obstacle.destroy_obstacle_below_screen(empty_model, 1)!

	assert empty_model == new_model
}

fn test_destroy_obstacle_below_screen_destroys_correct_obstacles() {
	test_model := world.WorldModel{
		obstacle_positions: [
			transform.Position{0, 0},
			transform.Position{0, 1},
			transform.Position{0, 2},
		]
	}

	new_model := obstacle.destroy_obstacle_below_screen(test_model, 1)!

	assert new_model.obstacle_positions == [transform.Position{0, 0}]
}

fn test_destroy_obstacle_below_screen_destroys_no_obstacles() {
	test_model := world.WorldModel{
		obstacle_positions: [
			transform.Position{0, 0},
			transform.Position{0, 1},
			transform.Position{0, 2},
		]
	}

	new_model := obstacle.destroy_obstacle_below_screen(test_model, 3)!

	assert new_model.obstacle_positions == test_model.obstacle_positions
}
