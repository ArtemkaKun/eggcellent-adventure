module chicken

import common

pub fn gravity_system(mut velocity_component common.Velocity, gravity_affection &GravityAffection) {
	velocity_component = &common.Velocity{
		x: velocity_component.x
		y: velocity_component.y + gravity_affection.gravity_force
	}
}

pub fn player_control_system_left_touch(_ &IsControlledByPlayerTag, mut rendering_metadata_component common.RenderingMetadata, mut velocity_component common.Velocity) {
	rendering_metadata_component = &common.RenderingMetadata{
		image_id: rendering_metadata_component.image_id
		orientation: common.Orientation.left
	}

	velocity_component = &common.Velocity{
		x: 0.45
		y: -1
	}
}

pub fn player_control_system_right_touch(_ &IsControlledByPlayerTag, mut rendering_metadata_component common.RenderingMetadata, mut velocity_component common.Velocity) {
	rendering_metadata_component = &common.RenderingMetadata{
		image_id: rendering_metadata_component.image_id
		orientation: common.Orientation.right
	}

	velocity_component = &common.Velocity{
		x: -0.45
		y: -1
	}
}
