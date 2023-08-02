module player_input

import chicken
import gg
import ecs

// react_on_input_event handles the input event and triggers chicken jump.
// For Android platform, it checks if a touch event has occurred.
// For other platforms, it checks if an arrow key has been pressed.
pub fn react_on_input_event(event &gg.Event, mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity, mut animation_component ecs.Animation, screen_width int) {
	$if android {
		if event.typ == .touches_began && event.num_touches > 0 {
			animation_component.current_frame_id = 0
			animation_component.next_frame_id = 1
			animation_component.time_left_to_next_frame_ms = 0

			animation_component.is_playing = true

			execute_chicken_jump_system(mut rendering_metadata_component, mut velocity_component,
				event.touches[0].pos_x > screen_width / 2)
		}
	} $else {
		if event.typ == .key_down && (event.key_code == .left || event.key_code == .right) {
			animation_component.current_frame_id = 0
			animation_component.next_frame_id = 1
			animation_component.time_left_to_next_frame_ms = 0

			animation_component.is_playing = true

			execute_chicken_jump_system(mut rendering_metadata_component, mut velocity_component,
				event.key_code == .right)
		}
	}
}

fn execute_chicken_jump_system(mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity, is_right_jump bool) {
	jump_system := if is_right_jump {
		chicken.player_control_system_right_jump
	} else {
		chicken.player_control_system_left_jump
	}

	jump_system(mut rendering_metadata_component, mut velocity_component)
}
