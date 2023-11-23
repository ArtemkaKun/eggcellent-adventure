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
import math
import gg

const (
	target_fps             = 120.0 // NOTE: 144.0 is a target value for my phone. Most phones should have 60.0 I think.
	time_step_seconds      = 1.0 / target_fps // NOTE: This should be used for all game logic. Analog of delta time is some engines.
	time_step_nanoseconds  = i64(time_step_seconds * 1e9) // NOTE: This is used only for game loop sleep.
	time_step_milliseconds = int(time_step_seconds * 1e3) // NOTE: This is used only for game loop sleep.
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

fn test(mut position ecs.Position, chicken_position_component ecs.Position, screen_height int, obstacle_height f64) {
	position = &ecs.Position{
		x: position.x
		y: (screen_height - obstacle_height) + ((screen_height - chicken_position_component.y) / 2)
	}
}

fn start_main_game_loop(mut app graphics.App, mut ecs_world ecs.World) {
	wait_for_graphic_app_initialization(app)

	screen_size := graphics.get_screen_size(app)
	images_scale := graphics.get_images_scale(app)

	obstacles_render_data := obstacle.create_obstacles_render_data(mut app) or {
		panic("Can't create obstacles render data - ${err}")
	}

	screen_width := screen_size.width
	get_screen_pixels := get_all_x_pixels(screen_width)

	egg_polygon_convex_parts := common.load_polygon_and_get_convex_parts(graphics.get_egg_animation_frames(app)[0].path,
		images_scale) or { panic("Can't load egg's polygon - ${err}") }

	egg_polygon_width := collision.calculate_polygon_collider_width(egg_polygon_convex_parts)
	egg_polygon_height := collision.calculate_polygon_collider_height(egg_polygon_convex_parts)

	bottom_obstacle_polygon_convex_parts := common.load_polygon_and_get_convex_parts(graphics.get_bottom_obstacle_image(app).path,
		images_scale) or { panic("Can't load side obstacle's polygon - ${err}") }

	polygon_width := collision.calculate_polygon_collider_width(bottom_obstacle_polygon_convex_parts)
	polygon_height := collision.calculate_polygon_collider_height(bottom_obstacle_polygon_convex_parts)

	// dynamic

	for graphics.is_quited(app) == false {
		spawn_menu_menu(screen_width, screen_size, mut app, mut ecs_world)
		graphics.invoke_frame_draw(mut app)

		for app.is_game_running == false {
			time.sleep(time_step_nanoseconds * time.nanosecond)
		}

		ecs.clear_world(mut ecs_world)

		for app.is_game_running == true {
			chicken_entity := chicken.spawn_chicken(mut ecs_world, screen_size, graphics.get_chicken_animation_frames(app),
				images_scale, time_step_seconds) or { panic("Can't spawn chicken - ${err}") }

			graphics.set_chicken_data(mut app, chicken_entity)

			mut obstacle_id := 1

			mut obstacle_spawner_stopwatch := time.new_stopwatch()
			obstacle_spawner_stopwatch.start()
			obstacle_spawner_stopwatch.start = obstacles_spawn_rate_milliseconds // HACK: to spawn first obstacle immediately.

			mut chicken_velocity_component := ecs.get_entity_component[ecs.Velocity](chicken_entity) or {
				panic('Chicken entity does not have velocity component!')
			}

			chicken_gravity_component := ecs.get_entity_component[chicken.GravityInfluence](chicken_entity) or {
				panic('Chicken entity does not have velocity component!')
			}

			chicken_position_component := ecs.get_entity_component[ecs.Position](chicken_entity) or {
				panic('Chicken entity does not have velocity component!')
			}

			obstacle.spawn_side_obstacles(app, images_scale, mut ecs_world, screen_width,
				obstacle_move_vector)

			bottom_obstacles_count := int(math.ceil(screen_width / polygon_width))

			mut bottom_obstacles_positions := []&ecs.Position{cap: bottom_obstacles_count}

			for obstacle_index in 0 .. bottom_obstacles_count {
				bottom_obstacle_entity := obstacle.spawn_bottom_obstacle(mut ecs_world,
					screen_size.height, polygon_height, bottom_obstacle_polygon_convex_parts,
					app, polygon_width, obstacle_index)

				bottom_obstacles_positions << ecs.get_entity_component[ecs.Position](bottom_obstacle_entity) or {
					panic('Bottom obstacle entity does not have position component!')
				}
			}

			mut egg_entities_to_remove_on_animation_end := []u64{}

			mut died := false

			for died == false {
				obstacle_id = try_spawn_obstacle_and_egg(mut obstacle_spawner_stopwatch, mut
					ecs_world, obstacles_render_data, screen_width, obstacle_id, mut app,
					get_screen_pixels, egg_polygon_convex_parts, egg_polygon_width, egg_polygon_height) or {
					panic("Can't spawn obstacle or egg - ${err}")
				}

				chicken.gravity_system(mut chicken_velocity_component, chicken_gravity_component)

				ecs.execute_system_with_two_components[ecs.Velocity, ecs.Position](ecs_world,
					ecs.movement_system)

				for index in 0 .. bottom_obstacles_positions.len {
					test(mut bottom_obstacles_positions[index], chicken_position_component,
						screen_size.height, polygon_height)
				}

				continue_side_obstacles(app, images_scale, mut ecs_world, screen_width,
					obstacle_move_vector) or { panic("Can't continue side obstacles - ${err}") }

				destroy_entities_below_screen(mut ecs_world, screen_size.height) or {}

				if ecs.check_if_entity_has_component[collision.Collider](chicken_entity) {
					is_chicken_dead := handle_collision(mut ecs_world, chicken_entity, mut
						egg_entities_to_remove_on_animation_end) or {
						panic("Can't handle collision - ${err}")
					}

					if is_chicken_dead {
						died = true
					}
				}

				play_animations(mut ecs_world) or { println("Can't play animations - ${err}") }

				remove_egg_entities_on_animation_end(mut egg_entities_to_remove_on_animation_end, mut
					ecs_world)

				graphics.invoke_frame_draw(mut app)

				time.sleep(time_step_nanoseconds * time.nanosecond)
			}

			app.is_game_running = false
			ecs.clear_world(mut ecs_world)
		}
	}
}

fn spawn_menu_menu(screen_width int, screen_size gg.Size, mut app graphics.App, mut ecs_world ecs.World) {
	// vfmt off
	ecs.register_entity(mut ecs_world, [
			ecs.Position{
			x: screen_width / 2 - graphics.get_image_width_by_id(mut app, graphics.get_menu_cannon_image(app).id) / 2
			y: screen_size.height - graphics.get_image_height_by_id(mut app, graphics.get_menu_cannon_image(app).id) - 35
		},
			ecs.RenderData{
			image_id: graphics.get_menu_cannon_image(app).id
			orientation: common.Orientation.right
		},
	])
	// vfmt on

	main_position_x := screen_width / 2 - graphics.get_image_width_by_id(mut app, graphics.get_menu_grass_image(app).id) / 2

	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: main_position_x
			y: screen_size.height - graphics.get_image_height_by_id(mut app, graphics.get_menu_grass_image(app).id)
		},
		ecs.RenderData{
			image_id: graphics.get_menu_grass_image(app).id
			orientation: common.Orientation.right
		},
	])

	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: 0 - graphics.get_image_width_by_id(mut app, graphics.get_menu_grass_image(app).id) +
				main_position_x
			y: screen_size.height - graphics.get_image_height_by_id(mut app, graphics.get_menu_grass_image(app).id)
		},
		ecs.RenderData{
			image_id: graphics.get_menu_grass_image(app).id
			orientation: common.Orientation.right
		},
	])

	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: main_position_x +
				graphics.get_image_width_by_id(mut app, graphics.get_menu_grass_image(app).id)
			y: screen_size.height - graphics.get_image_height_by_id(mut app, graphics.get_menu_grass_image(app).id)
		},
		ecs.RenderData{
			image_id: graphics.get_menu_grass_image(app).id
			orientation: common.Orientation.right
		},
	])

	// vfmt off
	start_game_button := ecs.register_entity(mut ecs_world, [
			ecs.Position{
			x: screen_width / 2 - graphics.get_image_width_by_id(mut app, graphics.get_menu_start_game_button(app).id) / 2
			y: screen_size.height / 2 - graphics.get_image_height_by_id(mut app, graphics.get_menu_start_game_button(app).id) / 2 +
			150
		},
			ecs.RenderData{
			image_id: graphics.get_menu_start_game_button(app).id
			orientation: common.Orientation.right
		},
	])
	// vfmt on

	position_component := ecs.get_entity_component[ecs.Position](start_game_button) or {
		panic("Can't get position component!")
	}

	graphics.set_menu_start_game_button_position(mut app, position_component)
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

fn spawn_egg(mut ecs_world ecs.World, mut app graphics.App, obstacle_id int, get_screen_pixels []int, polygon_convex_parts [][]transform.Position, polygon_width f64, polygon_height f64) ! {
	egg_image_id := graphics.get_egg_animation_frames(app)[0].id
	egg_image_width := graphics.get_image_width_by_id(mut app, egg_image_id)
	egg_image_height := graphics.get_image_height_by_id(mut app, egg_image_id)

	egg_x_position := egg.calculate_egg_x_position(ecs_world, egg_image_width, obstacle_id,
		get_screen_pixels)

	egg.spawn_egg(mut ecs_world, egg_x_position, egg_image_height, graphics.get_egg_animation_frames(app),
		obstacle_move_vector, polygon_convex_parts, polygon_width, polygon_height)!
}

fn destroy_entities_below_screen(mut ecs_world ecs.World, screen_height int) ! {
	query := ecs.query_for_two_components[ecs.Position, ecs.DestroyBelowScreen]
	entities_to_check := ecs.get_entities_with_query(ecs_world, query)

	for entity in entities_to_check {
		if ecs.get_entity_component[ecs.Position](entity)!.y >= screen_height {
			ecs.remove_entity(mut ecs_world, entity.id)!
		}
	}
}

fn handle_collision(mut ecs_world ecs.World, chicken_entity ecs.Entity, mut egg_entities []u64) !bool {
	query := ecs.query_for_two_components[ecs.Position, collision.Collider]
	entities_to_check := ecs.get_entities_with_query(ecs_world, query)

	for entity in entities_to_check {
		if collision.check_collision(chicken_entity, entity)! {
			if ecs.check_if_entity_has_component[egg.IsEggTag](entity) == true {
				mut animation_component := ecs.get_entity_component[ecs.Animation](entity)!
				animation_component.is_playing = true
				egg_entities << entity.id
			} else {
				ecs.remove_component[chicken.IsControlledByPlayerTag](mut ecs_world, chicken_entity.id)!
				ecs.remove_component[collision.Collider](mut ecs_world, chicken_entity.id)!

				return true
			}

			break
		}
	}

	return false
}

fn play_animations(mut ecs_world ecs.World) ! {
	query := ecs.query_for_two_components[ecs.Animation, ecs.RenderData]
	entities := ecs.get_entities_with_query(ecs_world, query)

	for entity in entities {
		mut animation_component := ecs.get_entity_component[ecs.Animation](entity)!
		mut render_data_component := ecs.get_entity_component[ecs.RenderData](entity)!

		ecs.animation_system(mut animation_component, mut render_data_component, time_step_milliseconds)
	}
}

fn remove_egg_entities_on_animation_end(mut egg_entities []u64, mut ecs_world ecs.World) {
	for id in egg_entities {
		mut animation_component := ecs.get_entity_component_by_entity_id[ecs.Animation](ecs_world,
			id) or { continue }

		if animation_component.is_playing == false {
			ecs.remove_entity(mut ecs_world, id) or { continue }
			egg_entities.delete(egg_entities.index(id))
		}
	}
}

fn continue_side_obstacles(app graphics.App, images_scale int, mut ecs_world ecs.World, screen_width int, obstacle_move_vector transform.Vector) ! {
	query := ecs.check_if_entity_has_component[obstacle.EndlessElement]
	entities_to_check := ecs.get_entities_with_query(ecs_world, query)

	for entity in entities_to_check {
		mut position := ecs.get_entity_component[ecs.Position](entity)!
		mut tag := ecs.get_entity_component[obstacle.EndlessElement](entity)!

		if position.y >= 0 && tag.already_continued == false {
			tag.already_continued = true

			position = &ecs.Position{
				x: position.x
				y: 0
			}

			obstacle.spawn_side_obstacles(app, images_scale, mut ecs_world, screen_width,
				obstacle_move_vector)
		}
	}
}
