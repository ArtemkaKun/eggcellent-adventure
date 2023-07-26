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

	first_position := ecs.get_entity_component[ecs.Position](first_entity)!
	first_render_data := ecs.get_entity_component[ecs.RenderData](first_entity)!

	mut first_moved_convex_polygons := [][]trnsfrm2d.Position{}

	for first_convex_polygon in first_collider.normalized_convex_polygons {
		mut first_moved_convex_polygon := []trnsfrm2d.Position{}

		for first_convex_polygon_vertex in first_convex_polygon {
			first_moved_convex_polygon_vertex := if first_render_data.orientation == common.Orientation.left {
				mut most_left_x := 0.0
				mut most_right_x := 0.0

				for polygon in first_collider.normalized_convex_polygons {
					for point in polygon {
						if point.x < most_left_x {
							most_left_x = point.x
						}

						if point.x > most_right_x {
							most_right_x = point.x
						}
					}
				}

				trnsfrm2d.Position{
					x: (-first_convex_polygon_vertex.x + (most_right_x - most_left_x)) +
						first_position.x
					y: first_convex_polygon_vertex.y + first_position.y
				}
			} else {
				trnsfrm2d.Position{
					x: first_convex_polygon_vertex.x + first_position.x
					y: first_convex_polygon_vertex.y + first_position.y
				}
			}

			first_moved_convex_polygon << first_moved_convex_polygon_vertex
		}

		first_moved_convex_polygons << first_moved_convex_polygon
	}

	second_position := ecs.get_entity_component[ecs.Position](second_entity)!
	second_render_data := ecs.get_entity_component[ecs.RenderData](second_entity)!

	mut second_moved_convex_polygons := [][]trnsfrm2d.Position{}

	for second_convex_polygon in second_collider.normalized_convex_polygons {
		mut second_moved_convex_polygon := []trnsfrm2d.Position{}

		for second_convex_polygon_vertex in second_convex_polygon {
			second_moved_convex_polygon_vertex := if second_render_data.orientation == common.Orientation.left {
				mut most_left_x := 0.0
				mut most_right_x := 0.0

				for polygon in second_collider.normalized_convex_polygons {
					for point in polygon {
						if point.x < most_left_x {
							most_left_x = point.x
						}

						if point.x > most_right_x {
							most_right_x = point.x
						}
					}
				}

				trnsfrm2d.Position{
					x: (-second_convex_polygon_vertex.x + (most_right_x - most_left_x)) +
						second_position.x
					y: second_convex_polygon_vertex.y + second_position.y
				}
			} else {
				trnsfrm2d.Position{
					x: second_convex_polygon_vertex.x + second_position.x
					y: second_convex_polygon_vertex.y + second_position.y
				}
			}

			second_moved_convex_polygon << second_moved_convex_polygon_vertex
		}

		second_moved_convex_polygons << second_moved_convex_polygon
	}

	for first_convex_polygon in first_moved_convex_polygons {
		for second_convex_polygon in second_moved_convex_polygons {
			if pcoll2d.check_collision(first_convex_polygon, second_convex_polygon)! {
				return true
			}
		}
	}

	return false
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
