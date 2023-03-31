module obstacle

import transform
import rand

pub const (
	screen_width_too_small_error     = 'screen_width must be at least 3 times bigger than obstacle_section_width!'
	min_blocks_count_too_small_error = 'min_blocks_count must be at least 2!'
	min_blocks_count_too_big_error   = 'min_blocks_count must be less than max possible count of obstacle blocks!'
)

pub fn spawn_random_width_obstacle(screen_width int, obstacle_section_width int, obstacle_section_height int, min_blocks_count int) ![]transform.Position {
	if screen_width < obstacle_section_width * 3 {
		return error(obstacle.screen_width_too_small_error)
	}

	if min_blocks_count < 2 {
		return error(obstacle.min_blocks_count_too_small_error)
	}

	screen_width_obstacle := spawn_screen_width_obstacle(screen_width, obstacle_section_width,
		obstacle_section_height)!

	if min_blocks_count >= screen_width_obstacle.len {
		return error(obstacle.min_blocks_count_too_big_error)
	}

	return randomize_obstacle_blocks_count(min_blocks_count, screen_width_obstacle)!
}

fn spawn_screen_width_obstacle(screen_width int, obstacle_section_width int, obstacle_section_height int) ![]transform.Position {
	obstacle_blocks_positions := calculate_new_obstacle_blocks_positions(screen_width,
		obstacle_section_width)!

	return place_obstacle_above_screen(obstacle_section_height, obstacle_blocks_positions)
}

fn calculate_new_obstacle_blocks_positions(screen_width int, obstacle_section_width int) ![]transform.Position {
	max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(screen_width,
		obstacle_section_width)!

	return calculate_obstacle_blocks_positions(obstacle_section_width, max_count_of_obstacle_blocks)!
}

fn place_obstacle_above_screen(obstacle_section_height int, obstacle_blocks_positions []transform.Position) []transform.Position {
	y_position_above_screen := 0 - obstacle_section_height

	mut obstacle_blocks_positions_above_screen := []transform.Position{cap: obstacle_blocks_positions.len}

	for obstacle_block_position in obstacle_blocks_positions {
		obstacle_blocks_positions_above_screen << transform.Position{
			x: obstacle_block_position.x
			y: y_position_above_screen
		}
	}

	return obstacle_blocks_positions_above_screen
}

fn randomize_obstacle_blocks_count(min_blocks_count int, screen_width_obstacle []transform.Position) ![]transform.Position {
	random_obstacle_width := rand.int_in_range(min_blocks_count, screen_width_obstacle.len)!

	return screen_width_obstacle[..random_obstacle_width]
}
