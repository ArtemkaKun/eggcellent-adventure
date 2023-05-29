module chicken

import common
import ecs

pub struct GravityAffection {
	ecs.ComponentBase
pub:
	gravity_force f64
}

pub struct IsControlledByPlayerTag {
	ecs.ComponentBase
}

pub struct Animation {
pub:
	frames_ids                 []int
	is_playing                 bool
	current_frame_id           int
	time_to_next_frame_seconds f64
	next_frame_id              ?int
}

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

pub fn player_control_system_right_touch(controlled_by_player_tag &IsControlledByPlayerTag, mut rendering_metadata_component common.RenderingMetadata, mut velocity_component common.Velocity) {
	rendering_metadata_component = &common.RenderingMetadata{
		image_id: rendering_metadata_component.image_id
		orientation: common.Orientation.right
	}

	velocity_component = &common.Velocity{
		x: -0.45
		y: -1
	}
}
