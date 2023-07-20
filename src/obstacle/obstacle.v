// This file implements methods of obstacle sections generation logic.

module obstacle

import artemkakun.trnsfrm2d as transform
import common

pub const (
	screen_width_smaller_than_zero_error          = 'screen_width' + must_be_greater_than_zero_error
	screen_width_smaller_than_section_width_error = 'screen_width must be greater than or equal section_width!'

	sections_count_smaller_than_zero_error        = 'sections_count' +
		must_be_greater_than_zero_error

	section_width_smaller_than_zero_error         = 'section_width' +
		must_be_greater_than_zero_error
)

const (
	must_be_greater_than_zero_error = ' must be greater than 0!'
)

// calculate_max_count_of_obstacle_sections calculates the maximum number of obstacle sections that can fit on the screen.
// The game is always played in portrait mode, but the screen size and scale can vary, so the maximum number of
// obstacle sections is determined based on the screen width and the width of the section.
//
// Note:
// - The `section_width` parameter should already have the scale applied to it.
// - Both `screen_width` and `section_width` must be greater than zero.
// - `screen_width` must be greater than or equal to `section_width`.
//
// Example:
// ```v
// screen_width = 1000
// section_width = 100
//
// max_count_of_obstacle_sections := calculate_max_count_of_obstacle_sections(screen_width, section_width)
// println(max_count_of_obstacle_sections) // 10
// ```
//
// Returns an error if the provided parameters do not meet the requirements.
pub fn calculate_max_count_of_obstacle_sections(screen_width int, section_width int) !int {
	validate_screen_width(screen_width)!
	validate_section_width(section_width)!

	if screen_width < section_width {
		return error(obstacle.screen_width_smaller_than_section_width_error)
	}

	return screen_width / section_width
}

// calculate_obstacle_sections_positions calculates the positions for a specified number of obstacle sections.
// The first position is always (0,0). Each subsequent position is offset from the previous one by `section_width` along the x-axis.
// The total number of positions generated is equal to `sections_count`.
//
// Note:
// - For all generated positions, y-coordinate is 0.
// - The `section_width` parameter should already have the scale applied.
// - Both `section_width` and `sections_count` must be greater than zero.
//
// Example:
// ```v
// section_width = 100
// sections_count = 5
// screen_width = 1000
// obstacle_side = Orientation.left
//
// positions := calculate_obstacle_sections_positions(sections_count, obstacle_side, section_width, screen_width)
// println(positions) // Output: [transform.Position{ x: 0, y: 0 }, transform.Position{ x: 100, y: 0 }, transform.Position{ x: 200, y: 0 }, transform.Position{ x: 300, y: 0 }, transform.Position{ x: 400, y: 0 }]
// ```
//
// Returns an error if the provided parameters do not meet the requirements.
pub fn calculate_obstacle_sections_positions(sections_count int, obstacle_side common.Orientation, section_width int, screen_width int) ![]transform.Position {
	if sections_count <= 0 {
		return error(obstacle.sections_count_smaller_than_zero_error)
	}

	mut positions := []transform.Position{cap: sections_count}

	for section_index in 0 .. sections_count {
		positions << transform.Position{
			x: calculate_x_position(section_index, obstacle_side, section_width, screen_width)!
		}
	}

	return positions
}

fn calculate_x_position(section_index int, obstacle_side common.Orientation, section_width int, screen_width int) !int {
	validate_section_width(section_width)!
	validate_screen_width(screen_width)!

	left_x_position := section_index * section_width

	if obstacle_side == common.Orientation.left {
		return left_x_position
	}

	return (screen_width - section_width) - left_x_position
}

fn validate_screen_width(screen_width int) ! {
	if screen_width <= 0 {
		return error(obstacle.screen_width_smaller_than_zero_error)
	}
}

fn validate_section_width(section_width int) ! {
	if section_width <= 0 {
		return error(obstacle.section_width_smaller_than_zero_error)
	}
}
