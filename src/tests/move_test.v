module main

import transform

fn test_move_with_0_speed_returns_an_error() {
	transform.move(transform.Vector{}, transform.Position{}, 0, 1) or {
		assert err.msg() == 'speed must be greater than 0!'
		return
	}

	assert false
}

fn test_move_with_negative_speed_returns_an_error() {
	transform.move(transform.Vector{}, transform.Position{}, -1, 1) or {
		assert err.msg() == "Don't use negative speed! Use a negative vector instead."
		return
	}

	assert false
}

fn test_move_with_0_delta_time_returns_an_error() {
	transform.move(transform.Vector{}, transform.Position{}, 1, 0) or {
		assert err.msg() == 'delta_time must be greater than 0!'
		return
	}

	assert false
}

fn test_move_with_negative_delta_time_returns_an_error() {
	transform.move(transform.Vector{}, transform.Position{}, 1, -1) or {
		assert err.msg() == 'delta_time must be greater than 0!'
		return
	}

	assert false
}

fn test_move_returns_expected_position() {
	old_position := transform.Position{
		x: 0
		y: 0
	}

	new_position := transform.move(transform.Vector{0, -1}, old_position, 1, 1)!

	assert new_position.x.eq_epsilon(0.0)
	assert new_position.y.eq_epsilon(-1.0)
}
