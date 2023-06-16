module obstacle

import transform
import rand
import ecs
import common
import collision

// ObstaclesRenderData is needed to couple graphical assets info, that will be used in obstacles spawning algorithm.
pub struct ObstaclesRenderData {
	obstacle_section_image_id     int
	obstacle_section_image_width  int
	obstacle_section_image_height int
	obstacle_endings              []ObstacleEndingRenderData
}

// ObstacleEndingRenderData is a structure that holds the information about the obstacle ending.
pub struct ObstacleEndingRenderData {
	image_id int
	y_offset int
	width    int
	height   int
}

// NOTE: This set a chance of spawning a single obstacle to 70%.
// We don't want to spawn double obstacles too often, because it is harder to play.
// This value may be adjusted in the future.
const single_obstacle_spawn_chance = 0.7

// spawn_obstacle spawns a new random width obstacle above the screen.
pub fn spawn_obstacle(mut ecs_world ecs.World, obstacle_graphical_assets_metadata ObstaclesRenderData, screen_width int, min_blocks_count int, move_vector transform.Vector, obstacle_id int) ! {
	mut random_width_obstacle := create_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
		min_blocks_count)!

	add_shared_components(mut random_width_obstacle, move_vector, obstacle_id)

	for section_entity in random_width_obstacle {
		ecs.register_entity(mut ecs_world, section_entity)
	}
}

fn create_random_width_obstacle(screen_width int, obstacle_graphical_assets_metadata ObstaclesRenderData, min_blocks_count int) ![][]ecs.Component {
	if rand.f32() < obstacle.single_obstacle_spawn_chance {
		random_orientation := unsafe {
			common.Orientation(rand.int_in_range(0, 2)!)
		}

		return create_single_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
			min_blocks_count, random_orientation)!
	} else {
		return spawn_double_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
			min_blocks_count)!
	}
}

fn spawn_double_random_width_obstacle(screen_width int, obstacle_graphical_assets_metadata ObstaclesRenderData, min_blocks_count int) ![][]ecs.Component {
	mut left_obstacle := create_single_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
		min_blocks_count, common.Orientation.left)!

	mut right_obstacle := create_single_random_width_obstacle(screen_width, obstacle_graphical_assets_metadata,
		min_blocks_count, common.Orientation.right)!

	adjust_obstacles_spacing(mut left_obstacle, mut right_obstacle, obstacle_graphical_assets_metadata.obstacle_section_image_width)!

	mut double_obstacle := [][]ecs.Component{}
	double_obstacle << left_obstacle
	double_obstacle << right_obstacle

	return double_obstacle
}

fn create_single_random_width_obstacle(screen_width int, obstacle_graphical_assets_metadata ObstaclesRenderData, min_blocks_count int, random_orientation common.Orientation) ![][]ecs.Component {
	random_width_obstacle := calculate_positions_for_new_obstacle(screen_width, obstacle_graphical_assets_metadata.obstacle_section_image_width,
		min_blocks_count, random_orientation)!

	return create_obstacle_sections_entities(random_width_obstacle, random_orientation,
		obstacle_graphical_assets_metadata)
}

fn create_obstacle_sections_entities(obstacle_sections_positions []transform.Position, random_orientation common.Orientation, obstacle_graphical_assets_metadata ObstaclesRenderData) ![][]ecs.Component {
	above_screen_obstacle := place_obstacle_above_screen(obstacle_graphical_assets_metadata.obstacle_section_image_height,
		obstacle_sections_positions)

	mut obstacle_sections := [][]ecs.Component{}

	for index, obstacle_sections_position in above_screen_obstacle {
		mut new_entity_components := []ecs.Component{}

		mut new_position := obstacle_sections_position
		mut new_image_id := obstacle_graphical_assets_metadata.obstacle_section_image_id
		mut new_image_width := obstacle_graphical_assets_metadata.obstacle_section_image_width
		mut new_image_height := obstacle_graphical_assets_metadata.obstacle_section_image_height

		if index == above_screen_obstacle.len - 1 {
			random_obstacle_ending := rand.element[ObstacleEndingRenderData](obstacle_graphical_assets_metadata.obstacle_endings)!

			// NOTE:
			// When performing calculations, the obstacle section width image is used, but the width of the endings differs.
			// For the left orientation, the ending's position is right next to the edge of the previous section block,
			// so no adjustment is needed.
			// However, for the right orientation, we must offset the ending image by the difference
			// between the ending image width and the obstacle section width.
			// Consequently, for left orientation, images are drawn from the screen edge to the center, while for right orientation,
			// images are drawn from the center to the screen edge.
			mut x_offset := 0

			if random_orientation == common.Orientation.right {
				x_offset = obstacle_graphical_assets_metadata.obstacle_section_image_width - random_obstacle_ending.width
			}

			new_position = transform.Position{
				x: obstacle_sections_position.x + x_offset
				y: obstacle_sections_position.y + random_obstacle_ending.y_offset
			}

			new_image_id = random_obstacle_ending.image_id
			new_image_width = random_obstacle_ending.width
			new_image_height = random_obstacle_ending.height
		}

		new_entity_components << ecs.Position{
			x: new_position.x
			y: new_position.y
		}

		new_entity_components << ecs.RenderData{
			image_id: new_image_id
			orientation: random_orientation
		}

		new_entity_components << collision.Collider{
			width: new_image_width
			height: new_image_height
			collidable_types: collision.CollisionType.chicken
			collider_type: collision.CollisionType.obstacle
		}

		obstacle_sections << new_entity_components
	}

	return obstacle_sections
}

fn place_obstacle_above_screen(obstacle_section_height int, obstacle_sections_positions []transform.Position) []transform.Position {
	// TODO: same in background vines
	y_position_above_screen := 0 - obstacle_section_height

	return obstacle_sections_positions.map(update_obstacle_section_position_y(it, y_position_above_screen))
}

fn update_obstacle_section_position_y(obstacle_section_position transform.Position, new_y int) transform.Position {
	return transform.Position{
		x: obstacle_section_position.x
		y: new_y
	}
}

// Off vfmt because code is quite long and vfmt chops it in ugly ways.
// vfmt off

fn adjust_obstacles_spacing(mut left_obstacle_sections [][]ecs.Component, mut right_obstacle_sections [][]ecs.Component, min_space_between_obstacles int) ! {
	for is_spacing_too_small(right_obstacle_sections.last(), left_obstacle_sections.last(), min_space_between_obstacles)! {
		if right_obstacle_sections.len > left_obstacle_sections.len {
			remove_first_obstacle_section(mut right_obstacle_sections, min_space_between_obstacles)!
		} else {
			remove_first_obstacle_section(mut left_obstacle_sections, min_space_between_obstacles * -1)! // NOTE: we need to shift left obstacle sections to the left, so we use negative value here.
		}
	}
}
// vfmt on

fn is_spacing_too_small(right_obstacle_ending_components []ecs.Component, left_obstacle_ending_components []ecs.Component, obstacle_section_width int) !bool {
	right_position := ecs.find_component[ecs.Position](right_obstacle_ending_components)!
	position_of_left_section_end := calculate_left_ending_end_position(left_obstacle_ending_components)!

	return right_position.x - position_of_left_section_end < obstacle_section_width
}

fn calculate_left_ending_end_position(left_obstacle_ending_components []ecs.Component) !f64 {
	left_position := ecs.find_component[ecs.Position](left_obstacle_ending_components)!
	left_collider := ecs.find_component[collision.Collider](left_obstacle_ending_components)!

	return left_position.x + left_collider.width
}

fn remove_first_obstacle_section(mut obstacle_sections [][]ecs.Component, obstacle_section_width int) ! {
	obstacle_sections.delete(0)

	for index, _ in obstacle_sections {
		mut position_component := ecs.find_component[ecs.Position](obstacle_sections[index])!
		component_index := obstacle_sections[index].index(position_component)

		obstacle_sections[index][component_index] = ecs.Position{
			x: position_component.x + obstacle_section_width
			y: position_component.y
		}
	}
}

fn add_shared_components(mut obstacle_sections [][]ecs.Component, move_vector transform.Vector, obstacle_id int) {
	for mut section_entity in obstacle_sections {
		section_entity << [
			ecs.Velocity{
				x: move_vector.x
				y: move_vector.y
			},
			ObstacleSection{
				obstacle_id: obstacle_id
			},
		]
	}
}
