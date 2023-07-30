module collision

import ecs
import common
import artemkakun.trnsfrm2d
import artemkakun.pcoll2d

// Collider component defines the collision properties of an entity.
// It includes dimensions (`width` and `height`), the collision types of entities it can collide with (`collidable_types`),
// and the collision type of the entity itself (`collider_type`).
pub struct Collider {
pub:
	normalized_convex_polygons [][]trnsfrm2d.Position
	collidable_types           CollisionType
	collider_type              CollisionType
	width                      f64
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
	first_collider := ecs.get_entity_component[Collider](first_entity)!
	second_collider := ecs.get_entity_component[Collider](second_entity)!

	is_first_can_collide_with_second := first_collider.collidable_types.has(second_collider.collider_type)
	is_second_can_collide_with_first := second_collider.collidable_types.has(first_collider.collider_type)

	if is_first_can_collide_with_second == false || is_second_can_collide_with_first == false {
		return false
	}

	first_global_polygon := calculate_global_polygons(first_entity)!
	second_global_polygon := calculate_global_polygons(second_entity)!

	for first_convex_polygon in first_global_polygon {
		for second_convex_polygon in second_global_polygon {
			if pcoll2d.check_collision(first_convex_polygon, second_convex_polygon)! {
				return true
			}
		}
	}

	return false
}

// calculate_global_polygons calculates global positions of the collider's polygons.
pub fn calculate_global_polygons(entity ecs.Entity) ![][]trnsfrm2d.Position {
	collider := ecs.get_entity_component[Collider](entity)!
	position := ecs.get_entity_component[ecs.Position](entity)!
	render_data := ecs.get_entity_component[ecs.RenderData](entity)!

	work_polygons := if render_data.orientation == common.Orientation.left {
		flip_polygons_by_x(collider.normalized_convex_polygons, collider.width)
	} else {
		collider.normalized_convex_polygons
	}

	return move_polygons(work_polygons, position.Position.Vector)
}

fn flip_polygons_by_x(polygons [][]trnsfrm2d.Position, main_polygon_width f64) [][]trnsfrm2d.Position {
	mut flipped_polygons := [][]trnsfrm2d.Position{}

	for polygon in polygons {
		mut flipped_polygon := []trnsfrm2d.Position{}

		for vertex in polygon {
			flipped_polygon << trnsfrm2d.Position{
				x: -vertex.x + main_polygon_width
				y: vertex.y
			}
		}

		flipped_polygons << flipped_polygon
	}

	return flipped_polygons
}

fn move_polygons(polygons [][]trnsfrm2d.Position, move_vector trnsfrm2d.Vector) [][]trnsfrm2d.Position {
	mut moved_polygons := [][]trnsfrm2d.Position{}

	for polygon in polygons {
		mut moved_polygon := []trnsfrm2d.Position{}

		for vertex in polygon {
			moved_polygon << trnsfrm2d.Position{
				x: vertex.x + move_vector.x
				y: vertex.y + move_vector.y
			}
		}

		moved_polygons << moved_polygon
	}

	return moved_polygons
}

// calculate_polygon_collider_width calculates the width of a polygon collider.
pub fn calculate_polygon_collider_width(polygon_parts [][]trnsfrm2d.Position) f64 {
	mut most_left_x := 0.0
	mut most_right_x := 0.0

	for polygon in polygon_parts {
		for vertex in polygon {
			if vertex.x < most_left_x {
				most_left_x = vertex.x
			}

			if vertex.x > most_right_x {
				most_right_x = vertex.x
			}
		}
	}

	return most_right_x - most_left_x
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
