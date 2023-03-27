module obstacle

import world
import transform

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
pub fn destroy_obstacle_below_screen(current_model world.WorldModel, screen_height int) !world.WorldModel {
	if current_model.obstacle_positions.len == 0 {
		return current_model
	}

	mut valid_obstacle_positions := []transform.Position{}

	for obstacle_position in current_model.obstacle_positions {
		if is_obstacle_block_below_screen(obstacle_position, screen_height)! == false {
			valid_obstacle_positions << obstacle_position
		}
	}

	return world.WorldModel{
		...current_model
		obstacle_positions: valid_obstacle_positions
	}
}
