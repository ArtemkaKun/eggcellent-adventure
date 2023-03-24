module main

import graphics
import time
import obstacle
import world
import transform

fn main() {
	mut app := graphics.create_app()
	spawn update_world(mut app)
	graphics.start_app(mut app)
}

fn update_world(mut app graphics.GraphicalApp) {
	wait_for_graphic_app_initialization(app)
	create_obstacle(mut app) or { panic(err) }

	time_step_seconds := 1.0 / 144.0
	time_step_nanoseconds := i64(time_step_seconds * 1e9)

	for graphics.is_quited(app) == false {
		move_obstacle(mut app, time_step_seconds) or { panic(err) }
		destroy_obstacle_below_screen(mut app) or { panic(err) }
		graphics.invoke_frame_draw(mut app)

		time.sleep(time_step_nanoseconds * time.nanosecond)
	}
}

// wait_for_graphic_app_initialization NOTE: Pass app by reference to be able to check if it is initialized (copy will be always false).
fn wait_for_graphic_app_initialization(app &graphics.GraphicalApp) {
	for graphics.is_initialized(app) == false {
		time.sleep(1)
	}
}

fn create_obstacle(mut app graphics.GraphicalApp) ! {
	new_model := generate_obstacle(app)!
	graphics.update_world_model(mut app, new_model)
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

fn move_obstacle(mut app graphics.GraphicalApp, delta_time f64) ! {
	new_model := move_obstacle_positions(app, delta_time)!
	graphics.update_world_model(mut app, new_model)
}

fn move_obstacle_positions(app graphics.GraphicalApp, delta_time f64) !world.WorldModel {
	mut new_obstacle_positions := []transform.Position{cap: graphics.get_world_model(app).obstacle_positions.len}

	for obstacle_position in graphics.get_world_model(app).obstacle_positions {
		new_obstacle_positions << transform.move(transform.Vector{0, 1}, obstacle_position,
			50, delta_time)!
	}

	return world.WorldModel{
		...graphics.get_world_model(app)
		obstacle_positions: new_obstacle_positions
	}
}

fn destroy_obstacle_below_screen(mut app graphics.GraphicalApp) ! {
	if graphics.get_world_model(app).obstacle_positions.len == 0 {
		return
	}

	mut valid_obstacle_positions := []transform.Position{}
	screen_size := graphics.get_screen_size(app)

	for obstacle_position in graphics.get_world_model(app).obstacle_positions {
		if obstacle.is_obstacle_block_below_screen(obstacle_position, screen_size.height)! == false {
			valid_obstacle_positions << obstacle_position
		}
	}

	new_model := world.WorldModel{
		...graphics.get_world_model(app)
		obstacle_positions: valid_obstacle_positions
	}

	graphics.update_world_model(mut app, new_model)
}
