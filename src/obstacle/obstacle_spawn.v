module obstacle

import transform
import rand

pub const (
	screen_width_too_small_error     = 'screen_width must be at least 3 times bigger than obstacle_section_width!'
	min_blocks_count_too_small_error = 'min_blocks_count must be at least 2!'
	min_blocks_count_too_big_error   = 'min_blocks_count must be less than max possible count of obstacle blocks!'
)

// spawn_random_width_obstacle Spawns obstacle with random width.
//
// ATTENTION!⚠ screen_width must be at least 3 times bigger than obstacle_section_width!
// ATTENTION!⚠ min_blocks_count must be at least 2!
// ATTENTION!⚠ min_blocks_count must be less than max possible count of obstacle blocks! (this value is variable and depends on screen_width. Safe value is 2)
pub fn spawn_random_width_obstacle(screen_width int, obstacle_section_width int, min_blocks_count int, obstacle_side Orientation) ![]transform.Position {
	if screen_width < obstacle_section_width * 3 {
		return error(obstacle.screen_width_too_small_error)
	}

	if min_blocks_count < 2 {
		return error(obstacle.min_blocks_count_too_small_error)
	}

	screen_width_obstacle := calculate_new_obstacle_blocks_positions(screen_width, obstacle_section_width,
		obstacle_side)!

	if min_blocks_count >= screen_width_obstacle.len {
		return error(obstacle.min_blocks_count_too_big_error)
	}

	return randomize_obstacle_blocks_count(min_blocks_count, screen_width_obstacle)!
}

fn calculate_new_obstacle_blocks_positions(screen_width int, obstacle_block_width int, obstacle_side Orientation) ![]transform.Position {
	max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(screen_width,
		obstacle_block_width)!

	return calculate_obstacle_blocks_positions(max_count_of_obstacle_blocks, obstacle_side,
		obstacle_block_width, screen_width)!
}

fn randomize_obstacle_blocks_count(min_blocks_count int, screen_width_obstacle []transform.Position) ![]transform.Position {
	random_obstacle_width := rand.int_in_range(min_blocks_count, screen_width_obstacle.len)!

	return screen_width_obstacle[..random_obstacle_width]
}
