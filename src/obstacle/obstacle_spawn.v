module obstacle

import transform
import world

// spawn_obstacle Spawns a new obstacle above the screen.
//
// Example:
// ```v
// current_model := world.WorldModel{}
//
// new_model := spawn_obstacle(current_model, 5, 1, 1)
//
// assert new_model.obstacle_positions == [
// 	transform.Position{ x: 0, y: -1 },
// 	transform.Position{ x: 1, y: -1 },
// 	transform.Position{ x: 2, y: -1 },
// 	transform.Position{ x: 3, y: -1 },
// 	transform.Position{ x: 4, y: -1 }
// ]
// ```
pub fn spawn_obstacle(current_model world.WorldModel, screen_width int, obstacle_section_width int, obstacle_section_height int) !world.WorldModel {
	obstacle_blocks_positions := calculate_new_obstacle_blocks_positions(screen_width,
		obstacle_section_width)!

	return world.WorldModel{
		...current_model
		obstacle_positions: shift_obstacles_to_be_above_screen(obstacle_section_height,
			obstacle_blocks_positions)
	}
}

fn calculate_new_obstacle_blocks_positions(screen_width int, obstacle_section_width int) ![]transform.Position {
	max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(screen_width,
		obstacle_section_width)!

	return calculate_obstacle_blocks_positions(obstacle_section_width, max_count_of_obstacle_blocks)!
}

fn shift_obstacles_to_be_above_screen(obstacle_section_height int, obstacle_blocks_positions []transform.Position) []transform.Position {
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
