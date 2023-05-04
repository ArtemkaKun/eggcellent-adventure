module world

import transform
import background_vines

pub const (
	image_height_smaller_than_zero_error = 'image_height must be greater than 0'
)

pub fn spawn_background_vine(current_model WorldModel, image_id int, image_height int, x_position f64, move_vector transform.Vector) !WorldModel {
	if image_height <= 0 {
		return error(world.image_height_smaller_than_zero_error)
	}

	y_position_above_screen := 0 - image_height

	mut new_background_vines := current_model.background_vines.clone()

	new_background_vines << [
		background_vines.BackgroundVinePart{
			position: transform.Position{
				x: x_position
				y: y_position_above_screen
			}
			image_id: image_id
			image_height: image_height
			move_vector: move_vector
		},
	]

	return WorldModel{
		...current_model
		background_vines: new_background_vines
	}
}

pub fn move_background_vines(current_model WorldModel) !WorldModel {
	return WorldModel{
		...current_model
		background_vines: current_model.background_vines.map(move_vine(it))
	}
}

fn move_vine(current_vine []background_vines.BackgroundVinePart) []background_vines.BackgroundVinePart {
	return current_vine.map(move_vine_part(it))
}

fn move_vine_part(vine_part background_vines.BackgroundVinePart) background_vines.BackgroundVinePart {
	return background_vines.BackgroundVinePart{
		...vine_part
		position: transform.move_position(vine_part.position, vine_part.move_vector)
	}
}

// continue_vines This function spawns a new vine part if the last vine part position is greater than 0 (lower than top screen edge) to continue the vine.
pub fn continue_vines(current_model WorldModel) WorldModel {
	return WorldModel{
		...current_model
		background_vines: current_model.background_vines.map(try_continue_vine(it))
	}
}

fn try_continue_vine(vine []background_vines.BackgroundVinePart) []background_vines.BackgroundVinePart {
	if vine.last().position.y >= 0 {
		return continue_vine(vine)
	} else {
		return vine
	}
}

fn continue_vine(vine []background_vines.BackgroundVinePart) []background_vines.BackgroundVinePart {
	mut new_vine := vine.clone()

	last_vine_part := vine.last()
	last_vine_part_position := last_vine_part.position

	new_vine[new_vine.len - 1] = background_vines.BackgroundVinePart{
		...last_vine_part
		position: transform.Position{
			x: last_vine_part_position.x
			y: 0
		}
	}

	new_vine << background_vines.BackgroundVinePart{
		...last_vine_part
		position: transform.Position{
			x: last_vine_part_position.x
			y: 0 - last_vine_part.image_height
		}
	}

	return new_vine
}
