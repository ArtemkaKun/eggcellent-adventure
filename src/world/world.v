// This file contains the implementation of common world related things.

module world

import transform

// WorldModel This is a structure that holds the current state of the world.
pub struct WorldModel {
pub:
	obstacles [][]transform.Position
}
