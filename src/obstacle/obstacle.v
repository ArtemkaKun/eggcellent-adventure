module obstacle

pub fn calculate_max_count_of_obstacle_blocks(screen_width int, block_width int) !int {
	if screen_width <= 0 {
		return error('screen_width must be greater than 0!')
	}

	if block_width <= 0 {
		return error('block_width must be greater than 0!')
	}

	if screen_width < block_width {
		return error('screen_width must be greater or equal than block_width!')
	}

	return screen_width / block_width
}
