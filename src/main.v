// This file contains logic of the main game loop and main function.

module main

import graphics
import time
import obstacle
import transform

const (
	target_fps                = 144.0
	time_step_seconds         = 1.0 / target_fps
	time_step_nanoseconds     = i64(time_step_seconds * 1e9) // NOTE: This is used only for game loop sleep.

	obstacle_moving_direction = transform.Vector{0, 1} // Down
	obstacle_moving_speed     = 50.0
)

fn main() {
	mut app := graphics.create_app()
	spawn start_world_loop(mut app)
	graphics.start_app(mut app)
}

fn start_world_loop(mut app graphics.GraphicalApp) {
	wait_for_graphic_app_initialization(app)

	screen_size := graphics.get_screen_size(app)

	model_with_spawned_obstacle := obstacle.spawn_obstacle(graphics.get_world_model(app),
		screen_size.width, graphics.get_obstacle_section_width(app), graphics.get_obstacle_section_height(app)) or {
		panic(err)
	}

	graphics.update_world_model(mut app, model_with_spawned_obstacle)

	for graphics.is_quited(app) == false {
		current_model := graphics.get_world_model(app)

		model_with_moved_obstacles := obstacle.move_obstacles(current_model, obstacle_moving_direction,
			obstacle_moving_speed, time_step_seconds) or { panic(err) }

		model_with_valid_obstacles := obstacle.destroy_obstacle_below_screen(model_with_moved_obstacles,
			screen_size.height) or { panic(err) }

		if model_with_valid_obstacles != current_model {
			graphics.update_world_model(mut app, model_with_valid_obstacles)
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
