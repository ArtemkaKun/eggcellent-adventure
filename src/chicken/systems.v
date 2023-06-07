module chicken

import ecs
import common

// NOTE:
// These constants are used to define the jump velocity of the chicken.
// They were adjusted manually to achieve the desired jump behavior.
// Don't change them unless you know what you are doing.
const (
	jump_velocity_x = 0.45
	jump_velocity_y = -1
)

// gravity_system applies the force of gravity to an entity's velocity.
// It adjusts the y component of the entity's velocity based on the gravity force.
pub fn gravity_system(mut velocity_component ecs.Velocity, gravity_affection &GravityInfluence) {
	velocity_component = &ecs.Velocity{
		x: velocity_component.x
		y: velocity_component.y + gravity_affection.force
	}
}

// player_control_system_left_jump is triggered on players pressing the left arrow key or touching the left side of the screen.
// This system is triggered from the corresponding App's input event.
// It modifies the rendering_metadata and velocity components of the chicken entity to reflect the jump action to the left.
pub fn player_control_system_left_jump(_ &IsControlledByPlayerTag, mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity) {
	do_jump(mut rendering_metadata_component, mut velocity_component, common.Orientation.left)
}

// player_control_system_right_jump is triggered on players pressing the right arrow key or touching the right side of the screen.
// This system is triggered from the corresponding App's input event.
// It modifies the rendering_metadata and velocity components of the chicken entity to reflect the jump action to the right.
pub fn player_control_system_right_jump(_ &IsControlledByPlayerTag, mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity) {
	do_jump(mut rendering_metadata_component, mut velocity_component, common.Orientation.right)
}

fn do_jump(mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity, jump_orientation common.Orientation) {
	rendering_metadata_component = &ecs.RenderData{
		image_id: rendering_metadata_component.image_id
		orientation: jump_orientation
	}

	mut new_x_velocity := chicken.jump_velocity_x

	if jump_orientation == common.Orientation.right {
		new_x_velocity = new_x_velocity * -1
	}

	velocity_component = &ecs.Velocity{
		x: new_x_velocity
		y: chicken.jump_velocity_y
	}
}
