// Common systems, that are used for multiple entities.

module ecs

// movement_system updates the position of an entity based on its velocity.
pub fn movement_system(velocity_component &Velocity, mut position_component Position) {
	position_component = &Position{
		x: position_component.x + velocity_component.x
		y: position_component.y + velocity_component.y
	}
}

pub fn animation_system(mut animation_component Animation, mut render_data_component RenderData, delta_time_milliseconds int) {
	if animation_component.is_playing {
		if animation_component.time_left_to_next_frame_ms > 0 {
			animation_component.time_left_to_next_frame_ms -= delta_time_milliseconds
		} else {
			if animation_component.next_frame_id == -1 {
				animation_component.is_playing = false
				animation_component.current_frame_id = 0
				animation_component.next_frame_id = 1
			} else {
				next_frame_id := if animation_component.next_frame_id + 1 >= animation_component.frames.len {
					-1
				} else {
					animation_component.next_frame_id + 1
				}

				animation_component.current_frame_id = animation_component.next_frame_id
				animation_component.next_frame_id = next_frame_id
				animation_component.time_left_to_next_frame_ms = animation_component.time_between_frames_ms
			}
		}

		render_data_component = &RenderData{
			...render_data_component
			image_id: animation_component.frames[animation_component.current_frame_id].id
		}
	}
}
