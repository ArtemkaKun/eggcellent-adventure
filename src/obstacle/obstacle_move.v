module obstacle

import world
import transform

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
pub fn move_obstacles(current_model world.WorldModel, direction transform.Vector, speed f64, delta_time_seconds f64) !world.WorldModel {
	if should_skip_operation(current_model) {
		return current_model
	}

	mut new_obstacles := [][]transform.Position{cap: current_model.obstacles.len}

	for obstacle in current_model.obstacles {
		mut new_section_positions := []transform.Position{cap: obstacle.len}

		for section_position in obstacle {
			new_section_positions << transform.move(direction, section_position, speed,
				delta_time_seconds)!
		}

		new_obstacles << new_section_positions
	}

	return world.WorldModel{
		...current_model
		obstacles: new_obstacles
	}
}
