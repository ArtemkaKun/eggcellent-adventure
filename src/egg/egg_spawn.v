module egg

import obstacle
import ecs
import common
import artemkakun.trnsfrm2d as transform
import collision

// spawn_egg adds a new egg entity into the ECS world
pub fn spawn_egg(mut ecs_world ecs.World, egg_x_position int, egg_image_path string, egg_image_height int, egg_image_id int, obstacle_move_vector transform.Vector, images_scale int) ! {
	polygon_convex_parts := common.load_polygon_and_get_convex_parts(egg_image_path, images_scale)!
	polygon_width := collision.calculate_polygon_collider_width(polygon_convex_parts)

	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: egg_x_position
			y: 0 - egg_image_height
		},
		ecs.RenderData{
			image_id: egg_image_id
			orientation: common.Orientation.right
		},
		ecs.Velocity{
			x: obstacle_move_vector.x
			y: obstacle_move_vector.y
		},
		collision.Collider{
			normalized_convex_polygons: polygon_convex_parts
			collidable_types: collision.CollisionType.chicken
			collider_type: collision.CollisionType.egg
			width: polygon_width
		},
		IsEggTag{},
	])
}

// calculate_egg_x_position calculates and returns the x position for the egg on the screen.
// It does this by first finding all free x pixels on the screen that are not occupied by obstacles.
// Then it calculates the middle position between the leftmost and rightmost free pixels, and
// adjusts this position by half the width of the egg image to ensure the egg will be centered in the free space.
//
// Returns the calculated x position for the egg on the screen.
pub fn calculate_egg_x_position(ecs_world ecs.World, screen_width int, egg_image_width int, obstacle_id int) int {
	free_pixel_x_positions := find_free_x_pixels(ecs_world, screen_width, obstacle_id)

	min_x_position := free_pixel_x_positions[0]
	max_x_position := free_pixel_x_positions.last()

	return ((max_x_position - min_x_position) / 2 + min_x_position) - egg_image_width / 2
}

fn find_free_x_pixels(ecs_world ecs.World, screen_width int, obstacle_id int) []int {
	mut x_pixels := get_all_x_pixels(screen_width)

	for obstacle in get_obstacle_sections_near_future_egg(ecs_world, obstacle_id) {
		// NOTE: continue will never be reached because of `get_obstacle_sections_near_future_egg` returns only entities with Position and Collider components.
		obstacle_position := ecs.get_entity_component[ecs.Position](obstacle) or { continue }
		obstacle_collider := ecs.get_entity_component[collision.Collider](obstacle) or { continue }

		// vfmt off
		for occupied_x_pixel in int(obstacle_position.x) .. int(obstacle_position.x) + int(obstacle_collider.width) {
			x_pixels[occupied_x_pixel] = -1
		}
		// vfmt on
	}

	return x_pixels.filter(it != -1)
}

fn get_all_x_pixels(screen_width int) []int {
	mut x_pixels := []int{}

	for pixel_x in 0 .. screen_width {
		x_pixels << pixel_x
	}

	return x_pixels
}

fn get_obstacle_sections_near_future_egg(ecs_world ecs.World, obstacle_id int) []ecs.Entity {
	query := ecs.query_for_three_components[ecs.Position, collision.Collider, obstacle.ObstacleSection]
	obstacles := ecs.get_entities_with_query(ecs_world, query)

	// NOTE: false will never be returned because of `query_for_three_components` returns only entities with Position, Collider and ObstacleSection components.
	return obstacles.filter((ecs.get_entity_component[obstacle.ObstacleSection](it) or { false }).obstacle_id == obstacle_id)
}
