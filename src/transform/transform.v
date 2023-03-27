module transform

// Position Describes a position in 2D space.
// Is similar to a vector, but for logical purposes name "Position" is used.
// f64 precision is used for now, but it may be changed to f32 in the future.
pub struct Position {
pub:
	x f64
	y f64
}

// move Moves a position in a given direction.
// Amount of movement is determined by speed and delta_time.
//
// ATTENTION!⚠ speed must be greater than zero. If you want to move in a negative direction, use a negative vector.
// ATTENTION!⚠ delta_time must be greater than zero.
//
// Example:
// ```v
// move(Vector{ x: 1, y: 0 }, Position{ x: 0, y: 0 }, 1, 1) == Position{ x: 1, y: 0 }
// ```
pub fn move(direction Vector, position Position, speed f64, delta_time f64) !Position {
	if speed.eq_epsilon(0.0) {
		return error('speed must be greater than 0!')
	}

	if speed < 0 {
		return error("Don't use negative speed! Use a negative vector instead.")
	}

	if delta_time.eq_epsilon(0.0) || delta_time < 0 {
		return error('delta_time must be greater than 0!')
	}

	normalized_direction := normalize_vector(direction)

	return Position{
		x: position.x + normalized_direction.x * speed * delta_time
		y: position.y + normalized_direction.y * speed * delta_time
	}
}
