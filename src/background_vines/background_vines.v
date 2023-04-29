module background_vines

import common
import transform

pub const count_of_background_vines = 6

pub struct BackgroundVineEntity {
	common.Entity
pub:
	image_height int
	move_vector  transform.Vector
}
