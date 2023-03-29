// This file contains logic of the main game loop and main function.

module main

import graphics
import time
import obstacle
import transform
import world

const (
	target_fps                   = 144.0 // NOTE: 144.0 is a target value for my phone. Most phones should have 60.0 I think.
	time_step_seconds            = 1.0 / target_fps // NOTE: This should be used for all game logic. Analog of delta time is some engines.
	time_step_nanoseconds        = i64(time_step_seconds * 1e9) // NOTE: This is used only for game loop sleep.

	obstacle_moving_direction    = transform.Vector{0, 1} // Down
	obstacle_moving_speed        = 50.0 // NOTE: 50.0 was set only for testing. It may change in the future.

	obstacles_spawn_rate_seconds = 5 // NOTE: 5 was set only for testing. It may change in the future.
	obstacle_min_blocks_count    = 2 // NOTE: there is no sense to spawn obstacles only with 1 block, but need to be discussed with Igor.
)

fn main() {
	mut app := graphics.create_app()
	spawn start_main_game_loop(mut app)
	graphics.start_app(mut app)
}

fn start_main_game_loop(mut app graphics.GraphicalApp) {
	wait_for_graphic_app_initialization(app)

	screen_size := graphics.get_screen_size(app)
	screen_width := screen_size.width
	obstacle_section_width := graphics.get_obstacle_section_width(app)
	obstacle_section_height := graphics.get_obstacle_section_height(app)

	spawn_first_obstacle(mut app, screen_width, obstacle_section_width, obstacle_section_height)

	mut obstacle_spawner_stopwatch := time.new_stopwatch()
	obstacle_spawner_stopwatch.start()

	for graphics.is_quited(app) == false {
		current_model := graphics.get_world_model(app)

		mut new_model := world.WorldModel{
			...current_model
		}

		new_model = obstacle.move_obstacles(new_model, obstacle_moving_direction, obstacle_moving_speed,
			time_step_seconds) or { panic(err) }

		new_model = obstacle.destroy_obstacle_below_screen(new_model, screen_size.height) or {
			panic(err)
		}

		if obstacle_spawner_stopwatch.elapsed().seconds() >= obstacles_spawn_rate_seconds {
			new_model = spawn_obstacle(new_model, screen_width, obstacle_section_width,
				obstacle_section_height) or { panic(err) }

			obstacle_spawner_stopwatch.restart()
		}

		if new_model != current_model {
			graphics.update_world_model(mut app, new_model)
			graphics.invoke_frame_draw(mut app)
		}

		time.sleep(time_step_nanoseconds * time.nanosecond)
	}
}

// wait_for_graphic_app_initialization NOTE: Pass app by reference to be able to check if it is initialized (copy will be always false).
fn wait_for_graphic_app_initialization(app &graphics.GraphicalApp) {
	for graphics.is_initialized(app) == false {
		time.sleep(1 * time.nanosecond)
	}
}

fn spawn_first_obstacle(mut app graphics.GraphicalApp, screen_width int, obstacle_section_width int, obstacle_section_height int) {
	model_with_first_spawned_obstacle := spawn_obstacle(graphics.get_world_model(app),
		screen_width, obstacle_section_width, obstacle_section_height) or { panic(err) }

	graphics.update_world_model(mut app, model_with_first_spawned_obstacle)
}

fn spawn_obstacle(current_model world.WorldModel, screen_width int, obstacle_section_width int, obstacle_section_height int) !world.WorldModel {
	return obstacle.spawn_obstacle(current_model, screen_width, obstacle_section_width,
		obstacle_section_height, obstacle_min_blocks_count)!
}
