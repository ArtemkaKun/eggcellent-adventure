module obstacle

import transform
import rand
import common

pub const (
	min_sections_count_too_small_error = 'min_sections_count must be at least 2!'
	min_sections_count_too_big_error   = 'min_sections_count must be less than max possible count of obstacle sections!'
)

const min_allowed_count_of_obstacle_sections = 2

// calculate_positions_for_new_obstacle generates a sequence of positions for an obstacle with a random width.
//
// This function first calculates the maximum possible number of sections an obstacle can have, based on the screen width
// and the width of each obstacle section. It then randomly selects a number of sections between `min_sections_count` and
// the maximum number of sections. The resulting sequence of positions represents an obstacle with a random width.
//
// The orientation of the obstacle (i.e., whether it appears from the left or right of the screen) is determined by the
// `obstacle_side` parameter.
//
// Parameters:
// - `screen_width`: The width of the screen. Must be at least three times the width of an obstacle section.
// - `obstacle_section_width`: The width of each section of the obstacle.
// - `min_sections_count`: The minimum number of sections the obstacle can have. Must be at least 2 and less than the maximum possible number of obstacle sections.
// - `obstacle_side`: The side from which the obstacle appears.
//
// Returns a sequence of positions representing the obstacle.
//
// Errors:
// - If `screen_width` is less than three times `obstacle_section_width`, an error with the message 'screen_width must be at least 3 times bigger than obstacle_section_width!' is returned.
// - If `min_sections_count` is less than 2, an error with the message 'min_sections_count must be at least 2!' is returned.
// - If `min_sections_count` is greater than or equal to the length of `screen_width_obstacle`, an error with the message 'min_sections_count must be less than max possible count of obstacle sections!' is returned.
pub fn calculate_positions_for_new_obstacle(screen_width int, obstacle_section_width int, min_sections_count int, obstacle_side common.Orientation) ![]transform.Position {
	if min_sections_count < obstacle.min_allowed_count_of_obstacle_sections {
		return error(obstacle.min_sections_count_too_small_error)
	}

	screen_width_obstacle := calculate_new_obstacle_sections_positions(screen_width, obstacle_section_width,
		obstacle_side)!

	if min_sections_count >= screen_width_obstacle.len {
		return error(obstacle.min_sections_count_too_big_error)
	}

	return randomize_obstacle_sections_count(min_sections_count, screen_width_obstacle)!
}

fn calculate_new_obstacle_sections_positions(screen_width int, obstacle_section_width int, obstacle_side common.Orientation) ![]transform.Position {
	max_count_of_obstacle_sections := calculate_max_count_of_obstacle_sections(screen_width,
		obstacle_section_width)!

	return calculate_obstacle_sections_positions(max_count_of_obstacle_sections, obstacle_side,
		obstacle_section_width, screen_width)!
}

fn randomize_obstacle_sections_count(min_sections_count int, screen_width_obstacle []transform.Position) ![]transform.Position {
	random_obstacle_width := rand.int_in_range(min_sections_count, screen_width_obstacle.len)!

	return screen_width_obstacle[..random_obstacle_width]
}
