module common

import transform
import ecs

pub struct Position {
	ecs.ComponentBase
	transform.Position
}

pub struct ScaleFactor {
pub:
	scale_factor int
}

pub struct DestroyIfBelowScreenTag {
	ecs.ComponentBase
}

pub struct RenderingMetadata {
	ecs.ComponentBase
pub:
	image_id    int
	orientation Orientation
}

pub struct Collider {
pub:
	width  int
	height int
}

pub struct Velocity {
	ecs.ComponentBase
	transform.Vector
}

pub enum Orientation {
	left
	right
}

pub fn movement_system(velocity_component &Velocity, mut position_component Position) {
	position_component = &Position{
		x: position_component.x + velocity_component.x
		y: position_component.y + velocity_component.y
	}
}
