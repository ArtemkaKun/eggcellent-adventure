module world

import common
import transform

pub const (
	image_height_smaller_than_zero_error = 'image_height must be greater than 0'
)

pub fn spawn_background_vine(current_model WorldModel, image_id int, image_height int, x_position f64) !WorldModel {
	if image_height <= 0 {
		return error(world.image_height_smaller_than_zero_error)
	}

	y_position_above_screen := 0 - image_height

	mut new_background_vines := current_model.background_vines.clone()

	new_background_vines << [
		common.Entity{
			position: transform.Position{
				x: x_position
				y: y_position_above_screen
			}
			image_id: image_id
		},
	]

	return WorldModel{
		...current_model
		background_vines: new_background_vines
	}
}

pub fn move_background_vines(current_model WorldModel, move_vector transform.Vector) !WorldModel {
	// TODO: Should not skip at all, since obstacles and vines are always here
	if should_skip_operation(current_model) {
		return current_model
	}

	return WorldModel{
		...current_model
		background_vines: current_model.background_vines.map(move_vine(it, move_vector))
	}
}

fn move_vine(current_vine []common.Entity, move_vector transform.Vector) []common.Entity {
	return current_vine.map(move_vine_part(it, move_vector))
}

fn move_vine_part(vine_part common.Entity, move_vector transform.Vector) common.Entity {
	return common.Entity{
		...vine_part
		position: transform.move_position(vine_part.position, move_vector)
	}
}

pub fn continue_vines(current_model WorldModel, image_height int) WorldModel {
	mut new_background_vines := [][]common.Entity{}

	for vine in current_model.background_vines {
		if vine.last().position.y >= 0 {
			mut new_vine := vine.clone()

			new_vine[new_vine.len - 1] = common.Entity{
				...vine.last()
				position: transform.Position{
					x: vine.last().position.x
					y: 0
				}
			}

			new_vine << common.Entity{
				...vine.last()
				position: transform.Position{
					x: vine.last().position.x
					y: 0 - image_height
				}
			}

			new_background_vines << new_vine
		} else {
			new_background_vines << vine
		}
	}

	return WorldModel{
		...current_model
		background_vines: new_background_vines
	}
}
