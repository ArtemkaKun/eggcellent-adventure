module main

import graphics
import time
import obstacle
import world

pub enum Command {
	generate_obstacle
}

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
			create_obstacle(mut app) or { panic(err) }
		}
	}
}

fn create_obstacle(mut app graphics.GraphicalApp) ! {
	new_model := update(app, Command.generate_obstacle)!
	graphics.update_world_model(mut app, new_model)
}

fn update(app graphics.GraphicalApp, command Command) !world.WorldModel {
	match command {
		.generate_obstacle {
			return generate_obstacle(app)!
		}
	}
}

fn generate_obstacle(app graphics.GraphicalApp) !world.WorldModel {
	screen_size := graphics.get_screen_size(app)
	obstacle_section_width := graphics.get_obstacle_section_width(app)

	max_count_of_obstacle_blocks := obstacle.calculate_max_count_of_obstacle_blocks(screen_size.width,
		obstacle_section_width)!

	obstacle_blocks_positions := obstacle.calculate_obstacle_blocks_positions(obstacle_section_width,
		max_count_of_obstacle_blocks)!

	return world.WorldModel{
		...graphics.get_world_model(app)
		obstacle_positions: obstacle_blocks_positions
	}
}
