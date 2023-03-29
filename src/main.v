// This file contains logic of the main game loop and main function.

module main

import graphics
import time
import obstacle
import transform
import world

const (
	target_fps                   = 144.0
	time_step_seconds            = 1.0 / target_fps
	time_step_nanoseconds        = i64(time_step_seconds * 1e9) // NOTE: This is used only for game loop sleep.

	obstacle_moving_direction    = transform.Vector{0, 1} // Down
	obstacle_moving_speed        = 50.0

	obstacles_spawn_rate_seconds = 5
	obstacle_min_blocks_count    = 2
)

fn main() {
	mut app := graphics.create_app()
	spawn start_world_loop(mut app)
	graphics.start_app(mut app)
}

fn start_world_loop(mut app graphics.GraphicalApp) {
	wait_for_graphic_app_initialization(app)

	screen_size := graphics.get_screen_size(app)

	model_with_first_spawned_obstacle := obstacle.spawn_obstacle(graphics.get_world_model(app),
		screen_size.width, graphics.get_obstacle_section_width(app), graphics.get_obstacle_section_height(app),
		obstacle_min_blocks_count) or { panic(err) }

	graphics.update_world_model(mut app, model_with_first_spawned_obstacle)

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
			new_model = obstacle.spawn_obstacle(new_model, screen_size.width, graphics.get_obstacle_section_width(app),
				graphics.get_obstacle_section_height(app), obstacle_min_blocks_count) or {
				panic(err)
			}

			obstacle_spawner_stopwatch.restart()
		}

		if new_model != current_model {
			graphics.update_world_model(mut app, new_model)
			graphics.invoke_frame_draw(mut app)
		}

		time.sleep(time_step_nanoseconds * time.nanosecond)
	}
}

// NOTE: Pass app by reference to be able to check if it is initialized (copy will be always false).

fn wait_for_graphic_app_initialization(app &graphics.GraphicalApp) {
	for graphics.is_initialized(app) == false {
		time.sleep(1 * time.nanosecond)
	}
}
