// Common components, that are used in multiple parts of the game.

module ecs

import transform
import common

// Position component represents the spatial location of an entity within the game world.
// It embeds the `Position` struct from the `transform` module.
pub struct Position {
	transform.Position
}

// Velocity component represents the speed and direction of an entity's movement.
// It embeds the `Vector` struct from the `transform` module.
pub struct Velocity {
	transform.Vector
}

// RenderData component contains metadata used for rendering an entity.
// This includes the image_id to identify the sprite and the orientation for sprite rotation.
pub struct RenderData {
pub:
	image_id    int
	orientation common.Orientation
}

// Collider component defines the collision properties of an entity.
// It includes dimensions (`width` and `height`), the collision types of entities it can collide with (`collidable_types`),
// and the collision type of the entity itself (`collider_type`).
pub struct Collider {
pub:
	width            int
	height           int
	collidable_types CollisionType
	collider_type    CollisionType
}

// CollisionType is an enum that categorizes entities for the purpose of collision detection, used in Collider  component.
// The flag attribute allows for multiple EntityType values to be combined, enabling entities to be categorized as multiple types.
[flag]
pub enum CollisionType {
	obstacle
	chicken
	egg
}

// HACK: This function is a workaround to a limitation in V's interface implementation.
// In V, a struct automatically implements an interface if it satisfies all of the interface's methods and fields.
// However, for our empty interface for components, no struct can satisfy it as there are no methods or fields to implement.
// This function tackles this issue by returning a struct as an interface type, tricking the compiler into believing the struct implements the interface.
// This approach, while unorthodox, allows for cleaner code as it avoids the need for an explicit base struct to be embedded in every component struct.
// To use a component struct in, it should be placed within a similar function.
// The function uses an array to accommodate multiple components, thereby preventing code duplication.
// This hack should be removed when interface for component will have methods or fields.
fn component_interface_hack() []Component {
	return [Position{}, Velocity{}, RenderData{}, Collider{}]
}
