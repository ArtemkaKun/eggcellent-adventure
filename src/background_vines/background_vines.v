// This file contains implementation of structs, that are related to background vines.

module background_vines

import common
import transform

pub const (
	// NOTE: this value is controlled by art representation. Since right now we have 6 different background vines assets,
	// we must have value 6 here. This value can be only changed when count of background vines was changed.
	background_vines_count  = 6

	// NOTE: this value is only needed for the logic that iterates over background vines IDs.
	// Since background ID starts from 1, and V's loop iteration range is described as for id in 1 .. exclusive_value,
	// we need to use `max_background_vines_id` as loop range last value.
	max_background_vines_id = background_vines_count + 1
)

pub struct BackgroundVinePart {
	common.Entity
pub:
	image_height int
	move_vector  transform.Vector
}
