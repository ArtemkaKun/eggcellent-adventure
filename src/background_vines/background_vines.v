module background_vines

import common
import transform

// NOTE: this value is controlled by art representation. Since right now we have 6 different background vines assets,
// we must have value 6 here. This value can be only changed when count of background vines was changed.
pub const count_of_background_vines = 6

pub struct BackgroundVinePart {
	common.Entity
pub:
	image_height int
	move_vector  transform.Vector
}
