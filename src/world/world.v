// This file contains the implementation of common world related things.

module world

import obstacle
import transform
import rand
import background_vines

// WorldModel This is a structure that holds the current state of the world.
pub struct WorldModel {
pub:
	obstacles        [][]obstacle.ObstacleSection
	background_vines [][]background_vines.BackgroundVineEntity
}

// ObstacleGraphicalAssetsMetadata This structure is needed couple graphical assets info, that will be used by obstacles.
pub struct ObstacleGraphicalAssetsMetadata {
	obstacle_section_image_id     int
	obstacle_section_image_width  int
	obstacle_section_image_height int
	obstacle_endings              []ObstacleEnding
}

// ObstacleEnding This is a structure that holds the information about the obstacle ending.
pub struct ObstacleEnding {
	image_id int
	y_offset int
}

struct ObstacleSetupParameters {
	obstacle_side             obstacle.Orientation
	obstacle_section_image_id int
	obstacle_endings          []ObstacleEnding
}

// NOTE: This set a chance of spawning a single obstacle to 70%.
// We don't want to spawn double obstacles too often, because it is harder to play.
// This value may be adjusted in the future.
const single_obstacle_spawn_chance = 0.7

// spawn_obstacle Spawns a new random width obstacle above the screen.
//
// ATTENTION!⚠ Produced obstacle will have minimum 2 blocks and maximum `max_count_of_obstacle_blocks - 1` blocks.
//
// Example:
// ```v
// current_model := world.WorldModel{}
//
// obstacle_graphical_assets_metadata := world.ObstacleGraphicalAssetsMetadata{
// 	obstacle_section_image_id: 1
// 	obstacle_section_image_width: 10
// 	obstacle_section_image_height: 10
// 	obstacle_endings: [
// 		world.ObstacleEnding{
// 			image_id: 1
// 			y_offset: 0
// 		}
// 	]
// }
//
// new_model := world.spawn_obstacle(current_model, obstacle_graphical_assets_metadata, 5, 2)!
//
// new_model == world.WorldModel{
// 	obstacles: [
// 		[
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 0
// 					y: -10
// 				}
// 				image_id: 1
// 				orientation: obstacle.Orientation.left
// 			},
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 10
// 					y: -10
// 				}
// 				image_id: 1
// 				orientation: obstacle.Orientation.left
// 			}
// 		]
// 	]
// }
// ```
pub fn spawn_obstacle(current_model WorldModel, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, screen_width int, min_blocks_count int) !WorldModel {
	mut new_obstacles := current_model.obstacles.clone()

	if rand.f32() < world.single_obstacle_spawn_chance {
		random_orientation := unsafe {
			obstacle.Orientation(rand.int_in_range(0, 2)!)
		}

		spawned_obstacle := spawn_single_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
			min_blocks_count, random_orientation)!

		new_obstacles << spawned_obstacle
	} else {
		spawned_obstacles := spawn_double_random_width_obstacles(screen_width, obstacle_graphical_assets_metadata,
			min_blocks_count)!

		new_obstacles << spawned_obstacles
	}

	return WorldModel{
		...current_model
		obstacles: new_obstacles
	}
}

fn spawn_single_random_width_obstacle(screen_width int, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, min_blocks_count int, random_orientation obstacle.Orientation) ![]obstacle.ObstacleSection {
	random_width_obstacle := obstacle.spawn_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata.obstacle_section_image_width,
		min_blocks_count, random_orientation)!

	return setup_new_obstacle(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		random_width_obstacle, random_orientation, obstacle_graphical_assets_metadata)
}

fn spawn_double_random_width_obstacles(screen_width int, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, min_blocks_count int) ![][]obstacle.ObstacleSection {
	mut left_obstacle_sections_positions := obstacle.spawn_random_width_obstacle(screen_width,
		obstacle_graphical_assets_metadata.obstacle_section_image_width, min_blocks_count,
		obstacle.Orientation.left)!

	mut right_obstacle_sections_positions := obstacle.spawn_random_width_obstacle(screen_width,
		obstacle_graphical_assets_metadata.obstacle_section_image_width, min_blocks_count,
		obstacle.Orientation.right)!

	adjust_obstacles_spacing(mut left_obstacle_sections_positions, mut right_obstacle_sections_positions,
		obstacle_graphical_assets_metadata.obstacle_section_image_width, min_blocks_count)

	left_obstacle := setup_new_obstacle(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		left_obstacle_sections_positions, obstacle.Orientation.left, obstacle_graphical_assets_metadata)!

	right_obstacle := setup_new_obstacle(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		right_obstacle_sections_positions, obstacle.Orientation.right, obstacle_graphical_assets_metadata)!

	return [left_obstacle, right_obstacle]
}

fn setup_new_obstacle(obstacle_section_height int, obstacle_sections_positions []transform.Position, random_orientation obstacle.Orientation, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata) ![]obstacle.ObstacleSection {
	above_screen_obstacle := place_obstacle_above_screen(obstacle_section_height, obstacle_sections_positions)

	setup_parameters := ObstacleSetupParameters{
		obstacle_side: random_orientation
		obstacle_section_image_id: obstacle_graphical_assets_metadata.obstacle_section_image_id
		obstacle_endings: obstacle_graphical_assets_metadata.obstacle_endings
	}

	return setup_obstacle(above_screen_obstacle, setup_parameters)!
}

fn place_obstacle_above_screen(obstacle_section_height int, obstacle_sections_positions []transform.Position) []transform.Position {
	// TODO: same in background vines
	y_position_above_screen := 0 - obstacle_section_height

	return obstacle_sections_positions.map(update_obstacle_section_position_y(it, y_position_above_screen))
}

fn update_obstacle_section_position_y(obstacle_section_position transform.Position, new_y int) transform.Position {
	return transform.Position{
		x: obstacle_section_position.x
		y: new_y
	}
}

fn setup_obstacle(obstacle_sections_positions []transform.Position, setup_parameters ObstacleSetupParameters) ![]obstacle.ObstacleSection {
	mut obstacle_sections := obstacle_sections_positions.map(create_obstacle_section(it,
		setup_parameters.obstacle_side, setup_parameters.obstacle_section_image_id))

	obstacle_sections_last_index := obstacle_sections.len - 1

	obstacle_sections[obstacle_sections_last_index] = transform_obstacle_section_in_ending(obstacle_sections[obstacle_sections_last_index],
		setup_parameters.obstacle_endings)!

	return obstacle_sections
}

fn create_obstacle_section(section_position transform.Position, obstacle_side obstacle.Orientation, obstacle_section_image_id int) obstacle.ObstacleSection {
	return obstacle.ObstacleSection{
		position: transform.Position{
			x: section_position.x
			y: section_position.y
		}
		orientation: obstacle_side
		image_id: obstacle_section_image_id
	}
}

fn transform_obstacle_section_in_ending(obstacle_section obstacle.ObstacleSection, obstacle_endings []ObstacleEnding) !obstacle.ObstacleSection {
	random_obstacle_ending := rand.element[ObstacleEnding](obstacle_endings)!

	return obstacle.ObstacleSection{
		...obstacle_section
		image_id: random_obstacle_ending.image_id
		position: transform.Position{
			...obstacle_section.position
			y: obstacle_section.position.y + random_obstacle_ending.y_offset
		}
	}
}

fn adjust_obstacles_spacing(mut left_obstacle []transform.Position, mut right_obstacle []transform.Position, obstacle_section_width int, min_blocks_count int) {
	mut should_remove_left := false

	for is_too_small_space_between_obstacles(right_obstacle.last(), left_obstacle.last(),
		obstacle_section_width * 2) {
		if should_remove_left {
			try_remove_last_obstacle_section_position(mut left_obstacle, min_blocks_count)
		} else {
			try_remove_last_obstacle_section_position(mut right_obstacle, min_blocks_count)
		}

		should_remove_left = !should_remove_left
	}
}

fn is_too_small_space_between_obstacles(right_obstacle_ending_position transform.Position, left_obstacle_ending_position transform.Position, min_distance_between_obstacles int) bool {
	return right_obstacle_ending_position.x - left_obstacle_ending_position.x < min_distance_between_obstacles
}

fn try_remove_last_obstacle_section_position(mut obstacle_sections_positions []transform.Position, min_blocks_count int) {
	if obstacle_sections_positions.len > min_blocks_count {
		obstacle_sections_positions.delete_last()
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
// 	obstacles: [
// 		[
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 0
// 					y: -10
// 				}
// 				image_id: 1
// 				orientation: obstacle.Orientation.left
// 			},
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 10
// 					y: -10
// 				}
// 				image_id: 1
// 				orientation: obstacle.Orientation.left
// 			}
// 		]
// 	]
// }
//
// move_vector := transform.Vector{
// 	x: obstacle_moving_direction.x * obstacle_moving_speed
// 	y: obstacle_moving_direction.y * obstacle_moving_speed
// }
//
// new_model := move_obstacles(current_model, move_vector)!
//
// assert new_model.obstacles == [
// 	[
// 		obstacle.ObstacleSection{
// 			position: transform.Position{
// 				x: 0
// 				y: 40
// 			}
// 			image_id: 1
// 			orientation: obstacle.Orientation.left
// 		},
// 		obstacle.ObstacleSection{
// 			position: transform.Position{
// 				x: 10
// 				y: 40
// 			}
// 			image_id: 1
// 			orientation: obstacle.Orientation.left
// 		}
// 	]
// ]
// ```
pub fn move_obstacles(current_model WorldModel, move_vector transform.Vector) !WorldModel {
	if should_skip_operation(current_model) {
		return current_model
	}

	return WorldModel{
		...current_model
		obstacles: current_model.obstacles.map(move_obstacle(it, move_vector))
	}
}

fn move_obstacle(current_obstacle []obstacle.ObstacleSection, move_vector transform.Vector) []obstacle.ObstacleSection {
	return current_obstacle.map(move_obstacle_section(it, move_vector))
}

fn move_obstacle_section(obstacle_section obstacle.ObstacleSection, move_vector transform.Vector) obstacle.ObstacleSection {
	return obstacle.ObstacleSection{
		...obstacle_section
		position: transform.move_position(obstacle_section.position, move_vector)
	}
}

// destroy_obstacle_below_screen Removes all obstacles that are below the screen.
// If the obstacle is on the edge of the screen, it will be removed as well.
//
// Example:
// ```v
//  current_model := world.WorldModel{
// 	obstacles: [
// 		[
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 0
// 					y: 10
// 				}
// 				image_id: 1
// 				orientation: obstacle.Orientation.left
// 			},
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 10
// 					y: 10
// 				}
// 				image_id: 1
// 				orientation: obstacle.Orientation.left
// 			}
// 		]
// 	]
// }
//
// 	destroy_obstacle_below_screen(current_model, 5) == world.WorldModel{
// 	obstacles: []
// }
// ```
pub fn destroy_obstacle_below_screen(current_model WorldModel, screen_height int) !WorldModel {
	if should_skip_operation(current_model) {
		return current_model
	}

	return WorldModel{
		...current_model
		obstacles: get_visible_obstacles(current_model.obstacles, screen_height)!
	}
}

fn should_skip_operation(current_model WorldModel) bool {
	return current_model.obstacles.len == 0
}

fn get_visible_obstacles(obstacles [][]obstacle.ObstacleSection, screen_height int) ![][]obstacle.ObstacleSection {
	return obstacles.filter(is_obstacle_below_screen(it, screen_height)! == false)
}

fn is_obstacle_below_screen(current_obstacle []obstacle.ObstacleSection, screen_height int) !bool {
	// NOTE: We can only check the first block of the obstacle, because all blocks have the same y position.
	return obstacle.is_obstacle_section_below_screen(current_obstacle[0].position, screen_height)!
}
