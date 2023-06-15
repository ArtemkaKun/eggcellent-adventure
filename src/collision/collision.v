module collision

import ecs

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

// check_collision checks if two entities are colliding (AABB collision box).
pub fn check_collision(first_entity ecs.Entity, second_entity ecs.Entity) !bool {
	first_position := ecs.get_entity_component[ecs.Position](first_entity)!
	first_collider := ecs.get_entity_component[Collider](first_entity)!

	second_position := ecs.get_entity_component[ecs.Position](second_entity)!
	second_collider := ecs.get_entity_component[Collider](second_entity)!

	is_first_can_collide_with_second := first_collider.collidable_types.has(second_collider.collider_type)
	is_second_can_collide_with_first := second_collider.collidable_types.has(first_collider.collider_type)

	if is_first_can_collide_with_second == false || is_second_can_collide_with_first == false {
		return false
	}

	is_x_overlap := first_position.x < second_position.x + second_collider.width
		&& first_position.x + first_collider.width > second_position.x

	is_y_overlap := first_position.y < second_position.y + second_collider.height
		&& first_position.y + first_collider.height > second_position.y

	return is_x_overlap && is_y_overlap
}

// HACK: This function is a workaround to a limitation in V's interface implementation.
// In V, a struct automatically implements an interface if it satisfies all of the interface's methods and fields.
// However, for our empty interface for components, no struct can satisfy it as there are no methods or fields to implement.
// This function tackles this issue by returning a struct as an interface type, tricking the compiler into believing the struct implements the interface.
// This approach, while unorthodox, allows for cleaner code as it avoids the need for an explicit base struct to be embedded in every component struct.
// To use a component struct in, it should be placed within a similar function.
// The function uses an array to accommodate multiple components, thereby preventing code duplication.
// This hack should be removed when interface for component will have methods or fields.
fn component_interface_hack() ecs.Component {
	return Collider{}
}
