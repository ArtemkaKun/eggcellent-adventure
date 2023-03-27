module main

import obstacle
import world
import transform

fn test_spawn_obstacle_works_with_empty_model() {
	empty_model := world.WorldModel{}
	new_model := obstacle.spawn_obstacle(empty_model, 1, 1, 1)!

	assert new_model.obstacle_positions == [transform.Position{0, -1}]
}

fn test_spawn_obstacle_works_with_non_empty_model() {
	non_empty_model := world.WorldModel{
		obstacle_positions: [transform.Position{0, 0}]
	}

	new_model := obstacle.spawn_obstacle(non_empty_model, 1, 1, 1)!

	assert new_model.obstacle_positions == [
		transform.Position{0, 0},
		transform.Position{0, -1},
	]
}
