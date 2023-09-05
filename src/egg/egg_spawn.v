module egg

import obstacle
import ecs
import common
import artemkakun.trnsfrm2d
import collision
import gg

// spawn_egg adds a new egg entity into the ECS world
pub fn spawn_egg(mut ecs_world ecs.World, egg_x_position int, egg_image_height int, egg_animation_frames []gg.Image, obstacle_move_vector trnsfrm2d.Vector, polygon_convex_parts [][]trnsfrm2d.Position, polygon_width f64, polygon_height f64) ! {
	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: egg_x_position
			y: 0 - egg_image_height
		},
		ecs.RenderData{
			image_id: egg_animation_frames[0].id
			orientation: common.Orientation.right
		},
		ecs.Animation{
			frames: egg_animation_frames
			time_between_frames_ms: 67
			current_frame_id: 0
			next_frame_id: 1
		},
		ecs.DestroyBelowScreen{},
		ecs.Velocity{
			x: obstacle_move_vector.x
			y: obstacle_move_vector.y
		},
		collision.Collider{
			normalized_convex_polygons: polygon_convex_parts
			collidable_types: collision.CollisionType.chicken
			collider_type: collision.CollisionType.egg
			width: polygon_width
			height: polygon_height
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
pub fn calculate_egg_x_position(ecs_world ecs.World, egg_image_width int, obstacle_id int, get_screen_pixels []int) int {
	free_pixel_x_positions := find_free_x_pixels(ecs_world, obstacle_id, get_screen_pixels)

	min_x_position := free_pixel_x_positions[0]
	max_x_position := free_pixel_x_positions.last()

	return ((max_x_position - min_x_position) / 2 + min_x_position) - egg_image_width / 2
}

fn find_free_x_pixels(ecs_world ecs.World, obstacle_id int, get_screen_pixels []int) []int {
	obstacle_endings := get_obstacle_endings_near_future_egg(ecs_world, obstacle_id)

	if obstacle_endings.len == 1 {
		obstacle_ending := obstacle_endings[0]

		obstacle_orientation := ecs.get_entity_component[ecs.RenderData](obstacle_ending) or {
			panic(err)
		}

		obstacle_position := ecs.get_entity_component[ecs.Position](obstacle_ending) or {
			panic(err)
		}

		obstacle_collider := ecs.get_entity_component[collision.Collider](obstacle_ending) or {
			panic(err)
		}

		if obstacle_orientation.orientation == common.Orientation.left {
			return get_screen_pixels[int(obstacle_position.x) + int(obstacle_collider.width)..]
		}

		return get_screen_pixels[..int(obstacle_position.x)]
	} else {
		first_obstacle_ending := obstacle_endings[0]
		second_obstacle_ending := obstacle_endings[1]

		first_obstacle_position := ecs.get_entity_component[ecs.Position](first_obstacle_ending) or {
			panic(err)
		}

		second_obstacle_position := ecs.get_entity_component[ecs.Position](second_obstacle_ending) or {
			panic(err)
		}

		first_obstacle_collider := ecs.get_entity_component[collision.Collider](first_obstacle_ending) or {
			panic(err)
		}

		second_obstacle_collider := ecs.get_entity_component[collision.Collider](second_obstacle_ending) or {
			panic(err)
		}

		first_obstacle_orientation := ecs.get_entity_component[ecs.RenderData](first_obstacle_ending) or {
			panic(err)
		}

		if first_obstacle_orientation.orientation == common.Orientation.left {
			return get_screen_pixels[int(first_obstacle_position.x) +
				int(first_obstacle_collider.width)..int(second_obstacle_position.x)]
		} else {
			return get_screen_pixels[int(second_obstacle_position.x) +
				int(second_obstacle_collider.width)..int(first_obstacle_position.x)]
		}
	}
}

fn get_obstacle_endings_near_future_egg(ecs_world ecs.World, obstacle_id int) []ecs.Entity {
	query := ecs.query_for_component[obstacle.ObstacleSection]
	obstacles := ecs.get_entities_with_query(ecs_world, query)

	mut obstacles_endings := []ecs.Entity{}

	for obstacle in obstacles {
		// NOTE: continue will never be executed because of `query_for_component` returns only entities with ObstacleSection component.
		obstacle_section := ecs.get_entity_component[obstacle.ObstacleSection](obstacle) or {
			continue
		}

		if obstacle_section.obstacle_id == obstacle_id && obstacle_section.is_ending {
			obstacles_endings << obstacle
		}
	}

	return obstacles_endings
}
