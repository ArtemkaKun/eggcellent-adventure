module chicken

import ecs
import common
import collision
import gg

// NOTE:
// These constants are used to define the jump velocity of the chicken.
// They were adjusted manually to achieve the desired jump behavior.
// Don't change them unless you know what you are doing.
const (
	jump_velocity_x = 0.6
	jump_velocity_y = -1.25
)

// spawn_chicken creates a new chicken entity and adds it to the world.
pub fn spawn_chicken(mut ecs_world ecs.World, screen_size gg.Size, chicken_animation_frames []gg.Image, image_scale int, time_step_seconds f64) !&ecs.Entity {
	polygon_convex_parts := common.load_polygon_and_get_convex_parts(chicken_animation_frames[0].path,
		image_scale)!

	polygon_width := collision.calculate_polygon_collider_width(polygon_convex_parts)

	return ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: screen_size.width / 2 - polygon_width / 2
			y: screen_size.height / 2
		},
		ecs.RenderData{
			image_id: chicken_animation_frames[0].id
			orientation: common.Orientation.right
		},
		ecs.Animation{
			frames: chicken_animation_frames
			time_between_frames_ms: 77
			current_frame_id: 0
			next_frame_id: 1
		},
		GravityInfluence{
			force: 2 * time_step_seconds
		},
		ecs.Velocity{},
		IsControlledByPlayerTag{},
		collision.Collider{
			normalized_convex_polygons: polygon_convex_parts
			collidable_types: collision.CollisionType.obstacle | collision.CollisionType.egg
			collider_type: collision.CollisionType.chicken
			width: polygon_width
			height: collision.calculate_polygon_collider_height(polygon_convex_parts)
		},
	])
}

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
pub fn player_control_system_left_jump(mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity) {
	do_jump(mut rendering_metadata_component, mut velocity_component, common.Orientation.left)
}

// player_control_system_right_jump is triggered on players pressing the right arrow key or touching the right side of the screen.
// This system is triggered from the corresponding App's input event.
// It modifies the rendering_metadata and velocity components of the chicken entity to reflect the jump action to the right.
pub fn player_control_system_right_jump(mut rendering_metadata_component ecs.RenderData, mut velocity_component ecs.Velocity) {
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
