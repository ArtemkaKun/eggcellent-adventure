// This file contains the implementation of common world related things.

module world

// WorldModel This is a structure that holds the current state of the world.
pub struct WorldModel {
pub:
	obstacle_positions []Position
}

// Position This is a simple game, so we use f32 instead of f64.
pub struct Position {
pub:
	x f32
	y f32
}
