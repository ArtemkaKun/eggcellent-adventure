module main

import graphics
import time
import obstacle
import world
import transform

pub enum Command {
	generate_obstacle
}

fn main() {
	mut app := graphics.create_app()
	spawn update_world(mut app)
	graphics.start_app(mut app)
}

fn update_world(mut app graphics.GraphicalApp) {
	wait_for_graphic_app_initialization(app)

	mut start_time := time.now()
	time_step_milliseconds := 1000.0 / 60.0

	for graphics.is_quited(app) == false {
		current_time := time.now()

		if current_time - start_time >= time_step_milliseconds {
			start_time = current_time
			create_obstacle(mut app) or { panic(err) }
		}
	}
}

// wait_for_graphic_app_initialization NOTE: Pass app by reference to be able to check if it is initialized (copy will be always false).
fn wait_for_graphic_app_initialization(app &graphics.GraphicalApp) {
	for graphics.is_initialized(app) == false {
		time.sleep(1)
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
	obstacle_section_width := graphics.get_obstacle_section_width(app)
	max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(app, obstacle_section_width)!
	obstacle_blocks_positions := obstacle.calculate_obstacle_blocks_positions(obstacle_section_width,
		max_count_of_obstacle_blocks)!

	y_position_above_screen := 0 - graphics.get_obstacle_section_height(app)

	mut obstacle_blocks_positions_above_screen := []transform.Position{cap: obstacle_blocks_positions.len}

	for obstacle_block_position in obstacle_blocks_positions {
		obstacle_blocks_positions_above_screen << transform.Position{
			x: obstacle_block_position.x
			y: y_position_above_screen
		}
	}

	return world.WorldModel{
		...graphics.get_world_model(app)
		obstacle_positions: obstacle_blocks_positions_above_screen
	}
}

fn calculate_max_count_of_obstacle_blocks(app graphics.GraphicalApp, obstacle_section_width int) !int {
	screen_size := graphics.get_screen_size(app)

	return obstacle.calculate_max_count_of_obstacle_blocks(screen_size.width, obstacle_section_width)!
}
