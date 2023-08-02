// This file contains logic of the main game loop and main function.

module main

import graphics
import time
import artemkakun.trnsfrm2d as transform
import ecs
import chicken
import egg
import obstacle
import collision
import common

const (
	target_fps            = 144.0 // NOTE: 144.0 is a target value for my phone. Most phones should have 60.0 I think.
	time_step_seconds     = 1.0 / target_fps // NOTE: This should be used for all game logic. Analog of delta time is some engines.
	time_step_nanoseconds = i64(time_step_seconds * 1e9) // NOTE: This is used only for game loop sleep.
)

const (
	obstacle_moving_direction         = transform.Vector{0, 1} // Down
	obstacle_moving_speed             = 50.0 // NOTE: 50.0 was set only for testing. It may change in the future.
	obstacles_spawn_rate_milliseconds = u64(5500) // NOTE: 5.5 seconds was set only for testing. It may change in the future.
	obstacle_min_blocks_count         = 2 // NOTE: these value was discussed with Igor and should not be changed without his approval.
	obstacle_move_vector              = transform.calculate_move_vector(obstacle_moving_direction,
		obstacle_moving_speed, time_step_seconds) or { panic(err) }
)

const egg_spawn_rate_obstacles = 2 // NOTE: this value means "spawn an egg every N obstacle"

fn main() {
	mut ecs_world := &ecs.World{}
	mut app := graphics.create_app(ecs_world)

	spawn start_main_game_loop(mut app, mut ecs_world)
	graphics.start_app(mut app)
}

fn start_main_game_loop(mut app graphics.App, mut ecs_world ecs.World) {
	wait_for_graphic_app_initialization(app)

	screen_size := graphics.get_screen_size(app)
	images_scale := graphics.get_images_scale(app)

	chicken_entity := chicken.spawn_chicken(mut ecs_world, screen_size, graphics.get_chicken_idle_image(app),
		images_scale, time_step_seconds) or { panic("Can't spawn chicken - ${err}") }

	graphics.set_chicken_data(mut app, chicken_entity)

	obstacles_render_data := obstacle.create_obstacles_render_data(mut app) or {
		panic("Can't create obstacles render data - ${err}")
	}

	mut obstacle_id := 1

	mut obstacle_spawner_stopwatch := time.new_stopwatch()
	obstacle_spawner_stopwatch.start()
	obstacle_spawner_stopwatch.start = obstacles_spawn_rate_milliseconds // HACK: to spawn first obstacle immediately.

	screen_width := screen_size.width
	get_screen_pixels := get_all_x_pixels(screen_width)

	egg_polygon_convex_parts := common.load_polygon_and_get_convex_parts(graphics.get_egg_1_image(app).path,
		images_scale) or { panic("Can't load egg's polygon - ${err}") }

	egg_polygon_width := collision.calculate_polygon_collider_width(egg_polygon_convex_parts)
	egg_polygon_height := collision.calculate_polygon_collider_height(egg_polygon_convex_parts)

	mut chicken_velocity_component := ecs.get_entity_component[ecs.Velocity](chicken_entity) or {
		panic('Chicken entity does not have velocity component!')
	}

	chicken_gravity_component := ecs.get_entity_component[chicken.GravityInfluence](chicken_entity) or {
		panic('Chicken entity does not have velocity component!')
	}

	for graphics.is_quited(app) == false {
		obstacle_id = try_spawn_obstacle_and_egg(mut obstacle_spawner_stopwatch, mut ecs_world,
			obstacles_render_data, screen_width, obstacle_id, mut app, get_screen_pixels,
			egg_polygon_convex_parts, egg_polygon_width, egg_polygon_height) or {
			panic("Can't spawn obstacle or egg - ${err}")
		}

		chicken.gravity_system(mut chicken_velocity_component, chicken_gravity_component)

		ecs.execute_system_with_two_components[ecs.Velocity, ecs.Position](ecs_world,
			ecs.movement_system)

		destroy_entities_below_screen(mut ecs_world, screen_size.height) or {}

		handle_collision(mut ecs_world, chicken_entity) or {
			println("Can't handle collision - ${err}")
		}

		graphics.invoke_frame_draw(mut app)

		time.sleep(time_step_nanoseconds * time.nanosecond)
	}
}

// wait_for_graphic_app_initialization NOTE: Pass app by reference to be able to check if it is initialized (copy will be always false).
fn wait_for_graphic_app_initialization(app &graphics.App) {
	for graphics.is_initialized(app) == false {
		time.sleep(1 * time.nanosecond)
	}
}

fn get_all_x_pixels(screen_width int) []int {
	mut x_pixels := []int{cap: screen_width}

	for pixel_x in 0 .. screen_width {
		x_pixels << pixel_x
	}

	return x_pixels
}

fn try_spawn_obstacle_and_egg(mut obstacle_spawner_stopwatch time.StopWatch, mut ecs_world ecs.World, obstacles_render_data obstacle.ObstaclesRenderData, screen_width int, obstacle_id int, mut app graphics.App, get_screen_pixels []int, egg_polygon_convex_parts [][]transform.Position, egg_polygon_width f64, egg_polygon_height f64) !int {
	if obstacle_spawner_stopwatch.elapsed().milliseconds() >= obstacles_spawn_rate_milliseconds {
		spawn_obstacle(mut ecs_world, obstacles_render_data, screen_width, obstacle_id)!

		if obstacle_id % egg_spawn_rate_obstacles == 0 {
			spawn_egg(mut ecs_world, mut app, obstacle_id, get_screen_pixels, egg_polygon_convex_parts,
				egg_polygon_width, egg_polygon_height)!
		}

		obstacle_spawner_stopwatch.restart()

		return obstacle_id + 1
	}

	return obstacle_id
}

fn spawn_obstacle(mut ecs_world ecs.World, obstacle_graphical_assets_metadata obstacle.ObstaclesRenderData, screen_width int, obstacle_id int) ! {
	obstacle.spawn_obstacle(mut ecs_world, obstacle_graphical_assets_metadata, screen_width,
		obstacle_min_blocks_count, obstacle_move_vector, obstacle_id)!
}

fn destroy_entities_below_screen(mut ecs_world ecs.World, screen_height int) ! {
	query := ecs.check_if_entity_has_component[ecs.Position]
	entities_to_check := ecs.get_entities_with_query(ecs_world, query)

	for entity in entities_to_check {
		if ecs.get_entity_component[ecs.Position](entity)!.y >= screen_height {
			ecs.remove_entity(mut ecs_world, entity.id)!
		}
	}
}

fn handle_collision(mut ecs_world ecs.World, chicken_entity ecs.Entity) ! {
	if ecs.check_if_entity_has_component[collision.Collider](chicken_entity) == false {
		return
	}

	query := ecs.query_for_two_components[ecs.Position, collision.Collider]
	entities_to_check := ecs.get_entities_with_query(ecs_world, query)

	for entity in entities_to_check {
		if collision.check_collision(chicken_entity, entity)! {
			if ecs.check_if_entity_has_component[egg.IsEggTag](entity) == true {
				ecs.remove_entity(mut ecs_world, entity.id)!
			} else {
				ecs.remove_component[chicken.IsControlledByPlayerTag](mut ecs_world, chicken_entity.id)!
				ecs.remove_component[collision.Collider](mut ecs_world, chicken_entity.id)!
			}

			break
		}
	}
}

fn spawn_egg(mut ecs_world ecs.World, mut app graphics.App, obstacle_id int, get_screen_pixels []int, polygon_convex_parts [][]transform.Position, polygon_width f64, polygon_height f64) ! {
	egg_image_id := graphics.get_egg_1_image(app).id
	egg_image_width := graphics.get_image_width_by_id(mut app, egg_image_id)
	egg_image_height := graphics.get_image_height_by_id(mut app, egg_image_id)

	egg_x_position := egg.calculate_egg_x_position(ecs_world, egg_image_width, obstacle_id,
		get_screen_pixels)

	egg.spawn_egg(mut ecs_world, egg_x_position, egg_image_height, egg_image_id, obstacle_move_vector,
		polygon_convex_parts, polygon_width, polygon_height)!
}
