// This file implements methods of obstacle block generation logic.

module obstacle

import transform
import world

pub const (
	screen_width_must_be_greater_than_zero_error                 = 'screen_width' +
		must_be_greater_than_zero_error

	screen_height_must_be_greater_than_zero_error                = 'screen_height' +
		must_be_greater_than_zero_error

	screen_width_must_be_greater_or_equal_than_block_width_error = 'screen_width must be greater than or equal block_width!'

	blocks_count_must_be_greater_than_zero_error                 = 'blocks_count' +
		must_be_greater_than_zero_error

	block_width_must_be_greater_than_zero_error                  = 'block_width' +
		must_be_greater_than_zero_error
)

const (
	must_be_greater_than_zero_error = ' must be greater than 0!'
)

// calculate_max_count_of_obstacle_blocks This method calculates the maximum count of obstacle blocks that can be placed on the screen.
// Since game is always played in the portrait mode, but can be played on any screen size with the different scale,
// we calculates the maximum count of obstacle blocks depending on the screen width and block width.
//
// ATTENTION!⚠ block_width must has scale applied to it.
// ATTENTION!⚠ block_width must be greater than zero.
// ATTENTION!⚠ screen_width must be greater than zero and greater or equal than block_width.
//
// Example:
// 	screen_width = 1000
// 	block_width = 100
//
// max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(screen_width, block_width)
// println(max_count_of_obstacle_blocks) -> 10
pub fn calculate_max_count_of_obstacle_blocks(screen_width int, block_width int) !int {
	if screen_width <= 0 {
		return error(obstacle.screen_width_must_be_greater_than_zero_error)
	}

	validate_block_width(block_width)!

	if screen_width < block_width {
		return error(obstacle.screen_width_must_be_greater_or_equal_than_block_width_error)
	}

	return screen_width / block_width
}

// calculate_obstacle_blocks_positions This method calculates the positions of obstacle blocks.
// The first position will be always 0, 0. The next position will be always the previous position + block_width.
// The count of positions will be equal to blocks_count.
//
// NOTE: for all calculated positions y will be 0.
//
// ATTENTION!⚠ block_width must has scale applied to it.
// ATTENTION!⚠ block_width must be greater than zero.
// ATTENTION!⚠ blocks_count must be greater than zero.
//
// Example:
// 	block_width = 100
// 	blocks_count = 5
//
// positions := calculate_obstacle_blocks_positions(block_width, blocks_count)
// println(positions) -> [Position{0, 0}, Position{100, 0}, Position{200, 0}, Position{300, 0}, Position{400, 0}]
pub fn calculate_obstacle_blocks_positions(block_width int, blocks_count int) ![]transform.Position {
	validate_block_width(block_width)!

	if blocks_count <= 0 {
		return error(obstacle.blocks_count_must_be_greater_than_zero_error)
	}

	return calculate_positions(block_width, blocks_count)
}

fn validate_block_width(block_width int) ! {
	if block_width <= 0 {
		return error(obstacle.block_width_must_be_greater_than_zero_error)
	}
}

fn calculate_positions(block_width int, blocks_count int) []transform.Position {
	mut positions := []transform.Position{cap: blocks_count}

	for block_index in 0 .. blocks_count {
		positions << transform.Position{
			x: block_index * block_width
		}
	}

	return positions
}

// is_obstacle_block_below_screen Checks if the obstacle block is below the screen.
// If the obstacle is on the edge of the screen, this method will return true.
//
// ATTENTION!⚠ screen_height must be greater than zero.
//
// Example:
// ```v
// 	position := transform.Position{ y: 15 }
// 	screen_height := 10
// 	is_obstacle_block_below_screen(position, screen_height) // true
// ```
pub fn is_obstacle_block_below_screen(position transform.Position, screen_height int) !bool {
	if screen_height <= 0 {
		return error(obstacle.screen_height_must_be_greater_than_zero_error)
	}

	return position.y >= screen_height
}
