module obstacle

import transform
import world
import rand

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
pub fn spawn_obstacle(current_model world.WorldModel, screen_width int, obstacle_section_width int, obstacle_section_height int) !world.WorldModel { // TODO: Screen width must be at least 3 times bigger than obstacle_section_width
	screen_width_obstacle := spawn_screen_width_obstacle(screen_width, obstacle_section_width,
		obstacle_section_height)!

	random_obstacle_width := rand.int_in_range(2, screen_width_obstacle.len)!
	trimmed_obstacle := screen_width_obstacle[..random_obstacle_width]

	mut new_obstacles := current_model.obstacles.clone()
	new_obstacles << trimmed_obstacle

	return world.WorldModel{
		...current_model
		obstacles: new_obstacles
	}
}

fn spawn_screen_width_obstacle(screen_width int, obstacle_section_width int, obstacle_section_height int) ![]transform.Position {
	obstacle_blocks_positions := calculate_new_obstacle_blocks_positions(screen_width,
		obstacle_section_width)!

	return place_obstacle_above_screen(obstacle_section_height, obstacle_blocks_positions)
}

fn calculate_new_obstacle_blocks_positions(screen_width int, obstacle_section_width int) ![]transform.Position {
	max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(screen_width,
		obstacle_section_width)!

	return calculate_obstacle_blocks_positions(obstacle_section_width, max_count_of_obstacle_blocks)!
}

fn place_obstacle_above_screen(obstacle_section_height int, obstacle_blocks_positions []transform.Position) []transform.Position {
	y_position_above_screen := 0 - obstacle_section_height

	mut obstacle_blocks_positions_above_screen := []transform.Position{cap: obstacle_blocks_positions.len}

	for obstacle_block_position in obstacle_blocks_positions {
		obstacle_blocks_positions_above_screen << transform.Position{
			x: obstacle_block_position.x
			y: y_position_above_screen
		}
	}

	return obstacle_blocks_positions_above_screen
}
