// This file contains logic of the main game loop and main function.

module main

import graphics
import time
import transform
import world
import ecs
import common
import chicken
import egg

const (
	target_fps            = 144.0 // NOTE: 144.0 is a target value for my phone. Most phones should have 60.0 I think.
	time_step_seconds     = 1.0 / target_fps // NOTE: This should be used for all game logic. Analog of delta time is some engines.
	time_step_nanoseconds = i64(time_step_seconds * 1e9) // NOTE: This is used only for game loop sleep.
)

const (
	obstacle_moving_direction    = transform.Vector{0, 1} // Down
	obstacle_moving_speed        = 50.0 // NOTE: 50.0 was set only for testing. It may change in the future.
	obstacles_spawn_rate_seconds = 5 // NOTE: 5 was set only for testing. It may change in the future.
	obstacle_min_blocks_count    = 2 // NOTE: these value was discussed with Igor and should not be changed without his approval.
)

const egg_spawn_rate_seconds = 20 // NOTE: 60 was set only for testing. It may change in the future.

fn main() {
	mut app := graphics.create_app()
	spawn start_main_game_loop(mut app)
	graphics.start_app(mut app)
}

fn start_main_game_loop(mut app graphics.App) {
	wait_for_graphic_app_initialization(app)

	screen_size := graphics.get_screen_size(app)
	screen_width := screen_size.width

	obstacle_graphical_assets_metadata := world.ObstacleGraphicalAssetsMetadata{
		obstacle_section_image_id: graphics.get_obstacle_section_right_image_id(app)
		obstacle_section_image_width: graphics.get_obstacle_section_width(mut app)
		obstacle_section_image_height: graphics.get_obstacle_section_height(mut app)
		obstacle_endings: graphics.get_obstacle_endings(mut app)
	}

	mut ecs_world := graphics.get_ecs_world(app)

	mut obstacle_id := 0

	spawn_obstacle(mut ecs_world, obstacle_graphical_assets_metadata, screen_width, obstacle_id) or {
		panic(err)
	}

	obstacle_id += 1

	chicken_idle_image_id := graphics.get_chicken_idle_image_id(app)

	ecs.register_entity(mut ecs_world, [
		common.Position{
			x: 100
			y: 100
		},
		common.RenderingMetadata{
			image_id: chicken_idle_image_id
			orientation: common.Orientation.right
		},
		chicken.GravityAffection{
			gravity_force: 2 * time_step_seconds
		},
		common.Velocity{},
		chicken.IsControlledByPlayerTag{},
		common.Collider{
			width: graphics.get_image_width_by_id(mut app, chicken_idle_image_id)
			height: graphics.get_image_height_by_id(mut app, chicken_idle_image_id)
			collision_mask: common.CollisionMask.obstacle | common.CollisionMask.egg
			collision_tag: common.CollisionMask.chicken
		},
	])

	mut obstacle_spawner_stopwatch := time.new_stopwatch()
	obstacle_spawner_stopwatch.start()

	mut egg_spawner_stopwatch := time.new_stopwatch()
	egg_spawner_stopwatch.start()

	for graphics.is_quited(app) == false {
		if obstacle_spawner_stopwatch.elapsed().seconds() >= obstacles_spawn_rate_seconds {
			spawn_obstacle(mut ecs_world, obstacle_graphical_assets_metadata, screen_width,
				obstacle_id) or { panic(err) }

			obstacle_spawner_stopwatch.restart()
			obstacle_id += 1
		}

		if egg_spawner_stopwatch.elapsed().seconds() >= egg_spawn_rate_seconds {
			spawn_egg(mut ecs_world, mut app, graphics.get_egg_1_image_id(app), screen_width) or {
				panic(err)
			}

			egg_spawner_stopwatch.restart()
		}

		ecs.execute_system_with_two_components[common.Velocity, chicken.GravityAffection](ecs_world,
			chicken.gravity_system) or {}

		ecs.execute_system_with_two_components[common.Velocity, common.Position](ecs_world,
			common.movement_system) or {}

		destroy_entities_below_screen(mut ecs_world, screen_size.height) or {}
		handle_collision(mut ecs_world) or {}

		graphics.invoke_frame_draw(mut app)

		time.sleep(time_step_nanoseconds * time.nanosecond)
	}
}

// wait_for_graphic_app_initialization NOTE: Pass app by reference to be able to check if it is initialized (copy will be always false).
fn wait_for_graphic_app_initialization(app &graphics.App) {
	for graphics.is_initialized(app) == false {
		time.sleep(1 * time.nanosecond)
	}
}

fn spawn_obstacle(mut ecs_world ecs.World, obstacle_graphical_assets_metadata world.ObstacleGraphicalAssetsMetadata, screen_width int, obstacle_id int) ! {
	world.spawn_obstacle(mut ecs_world, obstacle_graphical_assets_metadata, screen_width,
		obstacle_min_blocks_count, transform.calculate_move_vector(obstacle_moving_direction,
		obstacle_moving_speed, time_step_seconds)!, obstacle_id)!
}

fn destroy_entities_below_screen(mut ecs_world ecs.World, screen_height int) ! {
	entities_to_check := ecs.get_entities_with_two_components[common.Position, common.DestroyIfBelowScreenTag](ecs_world)!

	for entity in entities_to_check {
		if ecs.get_component[common.Position](entity)!.y >= screen_height {
			ecs.remove_entity(mut ecs_world, entity.id)
		}
	}
}

fn handle_collision(mut ecs_world ecs.World) ! {
	entities_to_check := ecs.get_entities_with_two_components[common.Position, common.Collider](ecs_world)!

	for first_index, entity_first in entities_to_check {
		for second_index in first_index + 1 .. entities_to_check.len {
			if check_collision(entity_first, entities_to_check[second_index])! {
				mut chicken_entity := entity_first
				mut second_collided_entity := entities_to_check[second_index]

				if ecs.check_if_entity_has_component[chicken.IsControlledByPlayerTag](entity_first) == false {
					if ecs.check_if_entity_has_component[chicken.IsControlledByPlayerTag](entities_to_check[second_index]) == false {
						panic('Two entities collided that are not suppose to collide.\n
								First entity is - ${entity_first}\n
								Second entity is = ${entities_to_check[second_index]}')
					}

					second_collided_entity = entity_first
					chicken_entity = entities_to_check[second_index]
				}

				if ecs.check_if_entity_has_component[egg.IsEggTag](second_collided_entity) == false {
					ecs.remove_component[chicken.IsControlledByPlayerTag](mut ecs_world,
						chicken_entity.id)!
					ecs.remove_component[common.Collider](mut ecs_world, chicken_entity.id)!
				} else {
					ecs.remove_entity(mut ecs_world, second_collided_entity.id)
				}

				break
			}
		}
	}
}

fn check_collision(first_entity ecs.Entity, second_entity ecs.Entity) !bool {
	first_position := ecs.get_component[common.Position](first_entity)!
	first_collider := ecs.get_component[common.Collider](first_entity)!

	second_position := ecs.get_component[common.Position](second_entity)!
	second_collider := ecs.get_component[common.Collider](second_entity)!

	if first_collider.collision_mask.has(second_collider.collision_tag) == false
		|| second_collider.collision_mask.has(first_collider.collision_tag) == false {
		return false
	}

	if first_position.x < second_position.x + second_collider.width
		&& first_position.x + first_collider.width > second_position.x
		&& first_position.y < second_position.y + second_collider.height
		&& first_position.y + first_collider.height > second_position.y {
		return true
	}

	return false
}

fn spawn_egg(mut ecs_world ecs.World, mut app graphics.App, egg_image_id int, screen_width int) ! {
	obstacles := ecs.get_entities_with_three_components[common.Position, common.Collider, world.Obstacle](ecs_world)!

	// We need to find a good position to spawn an egg. This position should be not occupied by the closest obstacle.
	// Implement an algorithm to find limits for egg spawning.
	mut closest_obstacle_by_y := obstacles[0]

	for entity in obstacles {
		if ecs.get_component[common.Position](entity)!.y < ecs.get_component[common.Position](closest_obstacle_by_y)!.y {
			closest_obstacle_by_y = entity
		}
	}

	closest_obstacles := obstacles.filter((ecs.get_component[world.Obstacle](it)!).id == (ecs.get_component[world.Obstacle](closest_obstacle_by_y)!).id)

	mut free_pixel_x_positions := []int{}

	for pixel_x in 0 .. screen_width + 1 {
		free_pixel_x_positions << pixel_x
	}

	for obstacle in closest_obstacles {
		obstacle_position := ecs.get_component[common.Position](obstacle)!
		obstacle_collider := ecs.get_component[common.Collider](obstacle)!

		for pixel_x in int(obstacle_position.x) .. int(obstacle_position.x) +
			obstacle_collider.width {
			index_of_element_to_mark_as_remove := free_pixel_x_positions.index(pixel_x)
			free_pixel_x_positions[index_of_element_to_mark_as_remove] = -1
		}
	}

	free_pixel_x_positions[free_pixel_x_positions.len - 1] = -1 // HACK

	free_pixel_x_positions = free_pixel_x_positions.filter(it != -1)

	min_x_position := free_pixel_x_positions[0]
	max_x_position := free_pixel_x_positions.last()

	egg_x_position := ((max_x_position - min_x_position) / 2 + min_x_position) - graphics.get_image_width_by_id(mut app,
		egg_image_id) / 2
	egg_y_position := 0 - graphics.get_image_height_by_id(mut app, egg_image_id)

	move_vector := transform.calculate_move_vector(obstacle_moving_direction, obstacle_moving_speed,
		time_step_seconds)!

	ecs.register_entity(mut ecs_world, [
		common.Position{
			x: egg_x_position
			y: egg_y_position
		},
		common.RenderingMetadata{
			image_id: egg_image_id
			orientation: common.Orientation.right
		},
		common.Velocity{
			x: move_vector.x
			y: move_vector.y
		},
		common.DestroyIfBelowScreenTag{},
		common.Collider{
			width: graphics.get_image_width_by_id(mut app, egg_image_id)
			height: graphics.get_image_height_by_id(mut app, egg_image_id)
			collision_mask: common.CollisionMask.chicken
			collision_tag: common.CollisionMask.egg
		},
		egg.IsEggTag{},
	])
}
