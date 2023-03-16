module obstacle

pub struct Position {
	x f32
	y f32
}

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

pub fn calculate_obstacle_blocks_positions(block_width int, blocks_count int) ![]Position {
	if block_width <= 0 {
		return error('block_width must be greater than 0!')
	}

	if blocks_count <= 0 {
		return error('blocks_count must be greater than 0!')
	}

	mut positions := []Position{}

	for block_index in 0 .. blocks_count {
		positions << Position{
			x: block_index * block_width
		}
	}

	return positions
}
