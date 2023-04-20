module main

import world
import transform
import obstacle

fn test_destroy_obstacle_below_screen_works_with_empty_model() {
	empty_model := world.WorldModel{}
	new_model := world.destroy_obstacle_below_screen(empty_model, 1)!

	assert empty_model == new_model
}

fn test_destroy_obstacle_below_screen_destroys_correct_obstacles() {
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
			],
			[
				obstacle.ObstacleSection{
					position: transform.Position{
						x: 0
						y: 1
					}
					orientation: obstacle.Orientation.left
					image_id: 0
				},
			],
			[
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

	new_model := world.destroy_obstacle_below_screen(test_model, 1)!

	assert new_model.obstacles == [
		[
			obstacle.ObstacleSection{
				position: transform.Position{
					x: 0
					y: 0
				}
				orientation: obstacle.Orientation.left
				image_id: 0
			},
		],
	]
}

fn test_destroy_obstacle_below_screen_destroys_no_obstacles() {
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

	new_model := world.destroy_obstacle_below_screen(test_model, 3)!

	assert new_model.obstacles == test_model.obstacles
}
