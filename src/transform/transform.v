module transform

// Position This is a simple game, so we use f32 instead of f64.
pub struct Position {
pub:
	x f32
	y f32
}

pub struct Vector {
	x f32
	y f32
}

pub fn move(direction Vector, position Position, speed f32, delta_time f32) !Position {
	if speed == 0 {
		return error('speed must be greater than 0!')
	}

	if speed < 0 {
		return error("Don't use negative speed! Use a negative vector instead.")
	}

	if delta_time <= 0 {
		return error('delta_time must be greater than 0!')
	}

	return Position{
		x: position.x + direction.x * speed * delta_time
		y: position.y + direction.y * speed * delta_time
	}
}
