// This file contains the implementation of common world related things.

module world

import obstacle
import transform
import rand

// WorldModel This is a structure that holds the current state of the world.
pub struct WorldModel {
pub:
	obstacles [][]obstacle.ObstacleSection
}

pub struct ObstacleEnding {
	image_id int
	y_offset int
}

// spawn_obstacle Spawns a new random width obstacle above the screen.
//
// ATTENTION!⚠ Produced obstacle will have minimum 2 blocks and maximum max_count_of_obstacle_blocks - 1 blocks.
//
// Example:
// ```v
// current_model := world.WorldModel{}
//
// new_model := spawn_obstacle(current_model, 5, 1, 1)
//
// // Possible output (result is random):
// assert new_model.obstacle_positions == [
// 	transform.Position{ x: 0, y: -1 },
// 	transform.Position{ x: 1, y: -1 },
// 	transform.Position{ x: 2, y: -1 },
// 	transform.Position{ x: 3, y: -1 }
// ]
// ```
pub fn spawn_obstacle(current_model WorldModel, obstacle_section_image_id int, obstacle_endings []ObstacleEnding, screen_width int, obstacle_section_width int, obstacle_section_height int, min_blocks_count int) !WorldModel {
	mut new_obstacles := current_model.obstacles.clone()

	random_orientation := unsafe { obstacle.Orientation(rand.int_in_range(0, 2)!) }

	random_width_obstacle := obstacle.spawn_random_width_obstacle(screen_width, obstacle_section_width,
		obstacle_section_height, min_blocks_count, random_orientation)!

	mut new_obstacle := []obstacle.ObstacleSection{}

	for position_index, section_position in random_width_obstacle {
		mut image_id := obstacle_section_image_id
		mut y_offset := 0

		if position_index == random_width_obstacle.len - 1 {
			random_obstacle_ending := rand.element[ObstacleEnding](obstacle_endings)!
			image_id = random_obstacle_ending.image_id
			y_offset = random_obstacle_ending.y_offset
		}

		new_obstacle << obstacle.ObstacleSection{
			position: transform.Position{
				x: section_position.x
				y: section_position.y + y_offset
			}
			orientation: random_orientation
			image_id: image_id
		}
	}

	new_obstacles << new_obstacle

	return WorldModel{
		...current_model
		obstacles: new_obstacles
	}
}

// move_obstacles Moves all obstacles in the world model.
// Speed is defined by obstacle_moving_speed constant.
// Direction is defined by obstacle_moving_direction constant.
//
// Example:
// ```v
// const (
//	obstacle_moving_speed     = 50.0
//	obstacle_moving_direction = transform.Vector{0, 1} // Down
//)
//
// current_model := world.WorldModel{
// 	obstacle_positions: [
// 		transform.Position{0, 0},
// 		transform.Position{0, 1},
// 		transform.Position{0, 2}
// 	]
// }
//
// new_model := move_obstacles(current_model, 1.0)
//
// assert new_model.obstacle_positions == [
// 	transform.Position{0, 50},
// 	transform.Position{0, 51},
// 	transform.Position{0, 52}
// ]
// ```
pub fn move_obstacles(current_model WorldModel, direction transform.Vector, speed f64, delta_time_seconds f64) !WorldModel {
	if should_skip_operation(current_model) {
		return current_model
	}

	mut new_obstacles := [][]obstacle.ObstacleSection{cap: current_model.obstacles.len}

	for obstacle_sections in current_model.obstacles {
		mut new_obstacle := []obstacle.ObstacleSection{cap: obstacle_sections.len}

		for obstacle_section in obstacle_sections {
			new_obstacle << obstacle.ObstacleSection{
				...obstacle_section
				position: transform.move(direction, obstacle_section.position, speed,
					delta_time_seconds)!
			}
		}

		new_obstacles << new_obstacle
	}

	return WorldModel{
		...current_model
		obstacles: new_obstacles
	}
}

// destroy_obstacle_below_screen Removes all obstacles that are below the screen.
// If the obstacle is on the edge of the screen, it will be removed as well.
//
// Example:
// ```v
//  current_model := world.WorldModel{
// 		obstacle_positions: [
// 			transform.Position{ x: 0, y: 0 },
// 			transform.Position{ x: 0, y: 1 },
// 			transform.Position{ x: 0, y: 2 },
// 			transform.Position{ x: 0, y: 3 },
// 			transform.Position{ x: 0, y: 4 },
// 			transform.Position{ x: 0, y: 5 }
// 		]
// 	}
//
// 	destroy_obstacle_below_screen(current_model, 3) == world.WorldModel{
// 		obstacle_positions: [
// 			transform.Position{ x: 0, y: 0 },
// 			transform.Position{ x: 0, y: 1 },
// 			transform.Position{ x: 0, y: 2 }
// 		]
// 	}
// ```
pub fn destroy_obstacle_below_screen(current_model WorldModel, screen_height int) !WorldModel {
	if should_skip_operation(current_model) {
		return current_model
	}

	mut valid_obstacles := [][]obstacle.ObstacleSection{}

	for obstacle_sections in current_model.obstacles {
		// NOTE: We can only check the first block of the obstacle, because all blocks have the same y position.
		if obstacle.is_obstacle_block_below_screen(obstacle_sections[0].position, screen_height)! == false {
			valid_obstacles << obstacle_sections
		}
	}

	return WorldModel{
		...current_model
		obstacles: valid_obstacles
	}
}

fn should_skip_operation(current_model WorldModel) bool {
	return current_model.obstacles.len == 0
}
