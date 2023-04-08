module main

import transform

fn test_move_returns_expected_position_when_only_x_moved() {
	old_position := transform.Position{
		x: 0
		y: 0
	}

	new_position := transform.move(old_position, transform.Vector{1, 0})!

	assert new_position.x.eq_epsilon(1)
	assert new_position.y.eq_epsilon(0)
}

fn test_move_returns_expected_position_when_only_y_moved() {
	old_position := transform.Position{
		x: 0
		y: 0
	}

	new_position := transform.move(old_position, transform.Vector{0, 1})!

	assert new_position.x.eq_epsilon(0)
	assert new_position.y.eq_epsilon(1)
}

fn test_move_returns_expected_position_when_both_coordinates_moved() {
	old_position := transform.Position{
		x: 0
		y: 0
	}

	new_position := transform.move(old_position, transform.Vector{1, 1})!

	assert new_position.x.eq_epsilon(1)
	assert new_position.y.eq_epsilon(1)
}

fn test_move_returns_expected_position_when_move_vector_is_negative() {
	old_position := transform.Position{
		x: 0
		y: 0
	}

	new_position := transform.move(old_position, transform.Vector{-1, -1})!

	assert new_position.x.eq_epsilon(-1)
	assert new_position.y.eq_epsilon(-1)
}
