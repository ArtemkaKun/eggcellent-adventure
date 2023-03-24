module obstacle

import world
import transform

const (
	obstacle_moving_speed     = 50.0
	obstacle_moving_direction = transform.Vector{0, 1} // Down
)

// move_obstacles Moves all obstacles in the world model.
// Speed is defined by obstacle_moving_speed constant.
// Direction is defined by obstacle_moving_direction constant.
//
// Example:
// ```v
// const (
//	obstacle_moving_speed     = 50.0
//	obstacle_moving_direction = transform.Vector(0, 1) // Down
//)
//
// current_model := world.WorldModel(
// 	obstacle_positions: [
// 		transform.Position(0, 0),
// 		transform.Position(0, 1),
// 		transform.Position(0, 2)
// 	]
// )
//
// new_model := move_obstacles(current_model, 1.0)
//
// assert new_model.obstacle_positions == [
// 	transform.Position(0, 50),
// 	transform.Position(0, 51),
// 	transform.Position(0, 52)
// ]
// ```
pub fn move_obstacles(current_model world.WorldModel, delta_time_seconds f64) !world.WorldModel {
	if current_model.obstacle_positions.len == 0 {
		return current_model
	}

	mut new_obstacle_positions := []transform.Position{cap: current_model.obstacle_positions.len}

	for obstacle_position in current_model.obstacle_positions {
		new_obstacle_positions << transform.move(obstacle.obstacle_moving_direction, obstacle_position,
			obstacle.obstacle_moving_speed, delta_time_seconds)!
	}

	return world.WorldModel{
		...current_model
		obstacle_positions: new_obstacle_positions
	}
}
