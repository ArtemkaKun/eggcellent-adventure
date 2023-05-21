// This file contains the implementation of common world related things.

module world

import obstacle
import transform
import rand
import ecs
import common

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
	width    int
}

struct ObstacleSetupParameters {
	obstacle_side                common.Orientation
	obstacle_section_image_id    int
	obstacle_endings             []ObstacleEnding
	move_vector                  transform.Vector
	obstacle_section_image_width int
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
// 				orientation: common.Orientation.left
// 			},
// 			obstacle.ObstacleSection{
// 				position: transform.Position{
// 					x: 10
// 					y: -10
// 				}
// 				image_id: 1
// 				orientation: common.Orientation.left
// 			}
// 		]
// 	]
// }
// ```
pub fn spawn_obstacle(mut ecs_world ecs.World, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, screen_width int, min_blocks_count int, move_vector transform.Vector) ! {
	if rand.f32() < world.single_obstacle_spawn_chance {
		random_orientation := unsafe {
			common.Orientation(rand.int_in_range(0, 2)!)
		}

		spawned_obstacle := spawn_single_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
			min_blocks_count, random_orientation, move_vector)!

		for obstacle_section in spawned_obstacle {
			ecs.register_entity(mut ecs_world, obstacle_section)
		}
	} else {
		left_obstacle, right_obstacle := spawn_double_random_width_obstacles(screen_width,
			obstacle_graphical_assets_metadata, min_blocks_count, move_vector)!

		for obstacle_section in left_obstacle {
			ecs.register_entity(mut ecs_world, obstacle_section)
		}

		for obstacle_section in right_obstacle {
			ecs.register_entity(mut ecs_world, obstacle_section)
		}
	}
}

fn spawn_single_random_width_obstacle(screen_width int, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, min_blocks_count int, random_orientation common.Orientation, move_vector transform.Vector) ![][]ecs.IComponent {
	random_width_obstacle := obstacle.spawn_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata.obstacle_section_image_width,
		min_blocks_count, random_orientation)!

	return setup_new_obstacle(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		random_width_obstacle, random_orientation, obstacle_graphical_assets_metadata,
		move_vector)
}

fn spawn_double_random_width_obstacles(screen_width int, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, min_blocks_count int, move_vector transform.Vector) !([][]ecs.IComponent, [][]ecs.IComponent) {
	mut left_obstacle_sections_positions := obstacle.spawn_random_width_obstacle(screen_width,
		obstacle_graphical_assets_metadata.obstacle_section_image_width, min_blocks_count,
		common.Orientation.left)!

	mut right_obstacle_sections_positions := obstacle.spawn_random_width_obstacle(screen_width,
		obstacle_graphical_assets_metadata.obstacle_section_image_width, min_blocks_count,
		common.Orientation.right)!

	adjust_obstacles_spacing(mut left_obstacle_sections_positions, mut right_obstacle_sections_positions,
		obstacle_graphical_assets_metadata.obstacle_section_image_width, min_blocks_count)

	left_obstacle := setup_new_obstacle(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		left_obstacle_sections_positions, common.Orientation.left, obstacle_graphical_assets_metadata,
		move_vector)!

	right_obstacle := setup_new_obstacle(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		right_obstacle_sections_positions, common.Orientation.right, obstacle_graphical_assets_metadata,
		move_vector)!

	return left_obstacle, right_obstacle
}

fn setup_new_obstacle(obstacle_section_height int, obstacle_sections_positions []transform.Position, random_orientation common.Orientation, obstacle_graphical_assets_metadata ObstacleGraphicalAssetsMetadata, move_vector transform.Vector) ![][]ecs.IComponent {
	above_screen_obstacle := place_obstacle_above_screen(obstacle_section_height, obstacle_sections_positions)

	setup_parameters := ObstacleSetupParameters{
		obstacle_side: random_orientation
		obstacle_section_image_id: obstacle_graphical_assets_metadata.obstacle_section_image_id
		obstacle_endings: obstacle_graphical_assets_metadata.obstacle_endings
		move_vector: move_vector
		obstacle_section_image_width: obstacle_graphical_assets_metadata.obstacle_section_image_width
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

fn setup_obstacle(obstacle_sections_positions []transform.Position, setup_parameters ObstacleSetupParameters) ![][]ecs.IComponent {
	mut obstacle_sections := [][]ecs.IComponent{}

	for index, obstacle_sections_position in obstacle_sections_positions {
		if index != obstacle_sections_positions.len - 1 {
			obstacle_sections << create_obstacle_section(obstacle_sections_position, setup_parameters.obstacle_side,
				setup_parameters.obstacle_section_image_id, setup_parameters.move_vector)
		} else {
			random_obstacle_ending := rand.element[ObstacleEnding](setup_parameters.obstacle_endings)!

			// NOTE:
			// When performing calculations, the obstacle section width image is used, but the width of the endings differs.
			// For the left orientation, the ending's position is right next to the edge of the previous section block,
			// so no adjustment is needed.
			// However, for the right orientation, we must offset the ending image by the difference
			// between the ending image width and the obstacle section width.
			// Consequently, for left orientation, images are drawn from the screen edge to the center, while for right orientation,
			// images are drawn from the center to the screen edge.
			mut x_offset := 0

			if setup_parameters.obstacle_side == common.Orientation.right {
				x_offset = setup_parameters.obstacle_section_image_width - random_obstacle_ending.width
			}

			position_with_offset := transform.Position{
				x: obstacle_sections_position.x + x_offset
				y: obstacle_sections_position.y + random_obstacle_ending.y_offset
			}

			obstacle_sections << create_obstacle_section(position_with_offset, setup_parameters.obstacle_side,
				random_obstacle_ending.image_id, setup_parameters.move_vector)
		}
	}

	return obstacle_sections
}

fn create_obstacle_section(section_position transform.Position, obstacle_side common.Orientation, obstacle_section_image_id int, move_vector transform.Vector) []ecs.IComponent {
	return [
		common.Position{
			x: section_position.x
			y: section_position.y
		},
		common.RenderingMetadata{
			image_id: obstacle_section_image_id
			orientation: obstacle_side
		},
		common.Velocity{
			x: move_vector.x
			y: move_vector.y
		},
		common.DestroyIfBelowScreenTag{},
	]
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
