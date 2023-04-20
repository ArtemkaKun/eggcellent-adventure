module main

import world
import transform
import obstacle

fn test_move_obstacles_works_with_empty_model() {
	empty_model := world.WorldModel{}
	move_vector := transform.calculate_move_vector(transform.Vector{ x: 0, y: 1 }, 1.0,
		1.0)!

	new_model := world.move_obstacles(empty_model, move_vector)!

	assert empty_model == new_model
}

fn test_move_obstacles_moves_obstacles_in_right_direction() {
	test_model := world.WorldModel{
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

	move_vector := transform.calculate_move_vector(transform.Vector{ x: 0, y: 1 }, 1.0,
		1.0)!

	new_model := world.move_obstacles(test_model, move_vector)!

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
	test_model := world.WorldModel{
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

	move_vector := transform.calculate_move_vector(transform.Vector{ x: 0, y: 1 }, 2.0,
		1.0)!

	new_model := world.move_obstacles(test_model, move_vector)!

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
