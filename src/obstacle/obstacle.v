// This file implements methods of obstacle block generation logic.

module obstacle

import transform
import common

pub const (
	screen_width_smaller_than_zero_error        = 'screen_width' + must_be_greater_than_zero_error
	screen_height_smaller_than_zero_error       = 'screen_height' + must_be_greater_than_zero_error
	screen_width_smaller_than_block_width_error = 'screen_width must be greater than or equal block_width!'
	blocks_count_smaller_than_zero_error        = 'blocks_count' + must_be_greater_than_zero_error
	block_width_smaller_than_zero_error         = 'block_width' + must_be_greater_than_zero_error
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
// ```v
// screen_width = 1000
// block_width = 100
//
// max_count_of_obstacle_blocks := calculate_max_count_of_obstacle_blocks(screen_width, block_width)
// println(max_count_of_obstacle_blocks) -> 10
// ```
pub fn calculate_max_count_of_obstacle_blocks(screen_width int, block_width int) !int {
	validate_screen_width(screen_width)!
	validate_block_width(block_width)!

	if screen_width < block_width {
		return error(obstacle.screen_width_smaller_than_block_width_error)
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
// ```v
// block_width = 100
// blocks_count = 5
// screen_width = 1000
// obstacle_side = Orientation.left
//
// positions := calculate_obstacle_blocks_positions(blocks_count, obstacle_side, block_width, screen_width)
// println(positions) -> [transform.Position{ x: 0, y: 0 }, transform.Position{ x: 100, y: 0 }, transform.Position{ x: 200, y: 0 }, transform.Position{ x: 300, y: 0 }, transform.Position{ x: 400, y: 0 }]
// ```
pub fn calculate_obstacle_blocks_positions(blocks_count int, obstacle_side common.Orientation, block_width int, screen_width int) ![]transform.Position {
	if blocks_count <= 0 {
		return error(obstacle.blocks_count_smaller_than_zero_error)
	}

	return calculate_positions(blocks_count, obstacle_side, block_width, screen_width)!
}

fn calculate_right_x_position(block_index int, block_width int, screen_width int) int {
	return (screen_width - block_width) - calculate_left_x_position(block_index, block_width)
}

fn calculate_left_x_position(block_index int, block_width int) int {
	return block_index * block_width
}

fn calculate_positions(blocks_count int, obstacle_side common.Orientation, block_width int, screen_width int) ![]transform.Position {
	mut positions := []transform.Position{cap: blocks_count}

	for block_index in 0 .. blocks_count {
		positions << transform.Position{
			x: calculate_x_position(block_index, obstacle_side, block_width, screen_width)!
		}
	}

	return positions
}

fn calculate_x_position(block_index int, obstacle_side common.Orientation, block_width int, screen_width int) !int {
	validate_block_width(block_width)!
	validate_screen_width(screen_width)!

	if obstacle_side == common.Orientation.left {
		return calculate_left_x_position(block_index, block_width)
	}

	return calculate_right_x_position(block_index, block_width, screen_width)
}

fn validate_screen_width(screen_width int) ! {
	if screen_width <= 0 {
		return error(obstacle.screen_width_smaller_than_zero_error)
	}
}

fn validate_block_width(block_width int) ! {
	if block_width <= 0 {
		return error(obstacle.block_width_smaller_than_zero_error)
	}
}

// is_obstacle_section_below_screen Checks if the obstacle block is below the screen.
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
pub fn is_obstacle_section_below_screen(position transform.Position, screen_height int) !bool {
	if screen_height <= 0 {
		return error(obstacle.screen_height_smaller_than_zero_error)
	}

	return position.y >= screen_height
}
