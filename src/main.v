module main

import graphics
import obstacle
import world
import time

fn main() {
	mut app := graphics.create_app()
	spawn update_world(mut app)
	graphics.start_app(mut app)
}

fn update_world(mut app graphics.GraphicalApp) {
	mut start_time := time.now()
	time_step_milliseconds := 1000.0 / 60.0

	for graphics.is_initialized(app) == false {
		time.sleep(1)
	}

	for graphics.is_quited(app) == false {
		current_time := time.now()

		if current_time - start_time >= time_step_milliseconds {
			start_time = current_time
			generate_obstacle(mut app)
		}
	}
}

fn generate_obstacle(mut app graphics.GraphicalApp) {
	screen_size := graphics.get_screen_size(app)
	obstacle_section_width := graphics.get_obstacle_section_width(app)

	max_count_of_obstacle_blocks := obstacle.calculate_max_count_of_obstacle_blocks(screen_size.width,
		obstacle_section_width) or {
		println(err)
		return
	}

	obstacle_blocks_positions := obstacle.calculate_obstacle_blocks_positions(obstacle_section_width,
		max_count_of_obstacle_blocks) or {
		println(err)
		return
	}

	graphics.update_model(mut app, world.Model{ obstacle_positions: obstacle_blocks_positions })
	graphics.trigger_frame_draw(mut app)
}
