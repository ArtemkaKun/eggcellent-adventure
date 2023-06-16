// Common systems, that are used for multiple entities.

module ecs

// movement_system updates the position of an entity based on its velocity.
pub fn movement_system(velocity_component &Velocity, mut position_component Position) {
	position_component = &Position{
		x: position_component.x + velocity_component.x
		y: position_component.y + velocity_component.y
	}
}
