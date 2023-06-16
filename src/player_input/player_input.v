module player_input

import chicken
import gg
import ecs

// react_on_input_event handles the input event and triggers chicken jump.
// For Android platform, it checks if a touch event has occurred.
// For other platforms, it checks if an arrow key has been pressed.
pub fn react_on_input_event(event &gg.Event, ecs_world ecs.World, screen_width int) {
	$if android {
		if event.typ == .touches_began && event.num_touches > 0 {
			execute_chicken_jump_system(ecs_world, event.touches[0].pos_x > screen_width / 2)
		}
	} $else {
		if event.typ == .key_down && (event.key_code == .left || event.key_code == .right) {
			execute_chicken_jump_system(ecs_world, event.key_code == .right)
		}
	}
}

fn execute_chicken_jump_system(ecs_world ecs.World, is_right_jump bool) {
	jump_system := if is_right_jump {
		chicken.player_control_system_right_jump
	} else {
		chicken.player_control_system_left_jump
	}

	ecs.execute_system_with_three_components[chicken.IsControlledByPlayerTag, ecs.RenderData, ecs.Velocity](ecs_world,
		jump_system)
}
