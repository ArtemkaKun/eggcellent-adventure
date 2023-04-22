module main

import world
import transform
import obstacle

fn test_move_obstacles_works_with_empty_model() {
	empty_model := world.WorldModel{}
	move_vector := get_default_test_vector()!

	assert move_obstacles(empty_model, move_vector)! == empty_model
}

fn test_move_obstacles_moves_obstacles_in_correct_direction() {
	test_model := get_test_world_model()
	move_vector := get_default_test_vector()!
	new_model := move_obstacles(test_model, move_vector)!

	assert new_model.obstacles == [
		[
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 1
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 2
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 3
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
		],
	]
}

fn test_move_obstacles_moves_obstacles_with_right_speed() {
	test_model := get_test_world_model()
	move_vector := get_test_vector(2)!
	new_model := move_obstacles(test_model, move_vector)!

	assert new_model.obstacles == [
		[
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 2
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 3
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 4
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
		],
	]
}

fn get_default_test_vector() !transform.Vector {
	return get_test_vector(1.0)!
}

fn get_test_vector(speed f64) !transform.Vector {
	return transform.calculate_move_vector(transform.Vector{ x: 0, y: 1 }, speed, 1.0)!
}

fn get_test_world_model() world.WorldModel {
	return world.WorldModel{
		obstacles: [
			[
				obstacle.ObstacleSection{
					position: transform.Position{
						x: 0
						y: 0
					}
					orientation: obstacle.Orientation.left
					image_id: 0
				},
				obstacle.ObstacleSection{
					position: transform.Position{
						x: 0
						y: 1
					}
					orientation: obstacle.Orientation.left
					image_id: 0
				},
				obstacle.ObstacleSection{
					position: transform.Position{
						x: 0
						y: 2
					}
					orientation: obstacle.Orientation.left
					image_id: 0
				},
			],
		]
	}
}

fn move_obstacles(model world.WorldModel, move_vector transform.Vector) !world.WorldModel {
	return world.move_obstacles(model, move_vector)!
}
