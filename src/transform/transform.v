module transform

pub const (
	speed_is_zero_error                = 'speed' + must_be_greater_than_zero_error
	negative_speed_error               = "Don't use negative speed! Use a negative vector instead."
	delta_time_smaller_than_zero_error = 'delta_time' + must_be_greater_than_zero_error
	direction_not_normalized           = 'direction vector must be normalized! Change speed parameter to influence movement speed.'
)

const (
	must_be_greater_than_zero_error = ' must be greater than 0!'
)

// Position Describes position in 2D space.
// It is the same as Vector, but for logical purposes name "Position" is used.
pub struct Position {
	Vector
}

// move Moves a position with move vector.
//
// Example:
// ```v
// move(Position{ x: 0, y: 0 }, Vector{ x: 1, y: 0 }) == Position{ x: 1, y: 0 }
// ```
pub fn move(position Position, move_vector Vector) !Position {
	return Position{
		x: position.x + move_vector.x
		y: position.y + move_vector.y
	}
}

// calculate_move_vector Calculates move vector based on direction, speed, and delta time.
//
// ATTENTION!⚠ direction vector must be normalized.
// ATTENTION!⚠ speed must be greater than zero. If you want to move in a negative direction, use a negative vector.
// ATTENTION!⚠ delta_time must be greater than zero.
//
// Example:
// ```v
// calculate_move_vector(Vector{0, 1}, 2, 1) == Vector{x: 0, y: 2}
// ```
pub fn calculate_move_vector(direction Vector, speed f64, delta_time f64) !Vector {
	if is_vector_normalized(direction) == false {
		return error(transform.direction_not_normalized)
	}

	if speed.eq_epsilon(0.0) {
		return error(transform.speed_is_zero_error)
	}

	if speed < 0 {
		return error(transform.negative_speed_error)
	}

	if delta_time.eq_epsilon(0.0) || delta_time < 0 {
		return error(transform.delta_time_smaller_than_zero_error)
	}

	speed_per_frame := speed * delta_time

	return Vector{direction.x * speed_per_frame, direction.y * speed_per_frame}
}
