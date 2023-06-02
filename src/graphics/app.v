// This file implements graphical app, that manages all graphical things like window, rendering, etc.

module graphics

import gg
import gx
import scale_factor
import math
import ecs
import common
import chicken
import world

// NOTE:
// Window size on Android works a bit like changing DPI, since app in the full screen mode all the time.
// For now I just set it to half of the my phone's screen size (Xiaomi Mi 10T).
const (
	window_width_pixels  = 540
	window_height_pixels = 1200
)

const (
	obstacle_section_right_image_name                = 'obstacle_section_right.png'

	obstacle_ending_simple_right_image_name          = 'obstacle_ending_simple_right.png'
	obstacle_ending_closed_bud_up_right_image_name   = 'obstacle_ending_closed_bud_up_right.png'
	obstacle_ending_closed_bud_down_right_image_name = 'obstacle_ending_closed_bud_down_right.png'
	obstacle_ending_bud_right_image_name             = 'obstacle_ending_bud_right.png'
	obstacle_ending_bud_eye_right_image_name         = 'obstacle_ending_bud_eye_right.png'
)

// ATTENTION!⚠ These values were carefully selected by hand to make the game look good. Don't change them without a good reason.
const (
	obstacle_ending_image_name_to_y_offset_map = {
		obstacle_ending_simple_right_image_name:          2
		obstacle_ending_closed_bud_up_right_image_name:   -1
		obstacle_ending_closed_bud_down_right_image_name: 1
		obstacle_ending_bud_right_image_name:             -2
		obstacle_ending_bud_eye_right_image_name:         -2
	}
)

const (
	// NOTE: This value is needed to influence scale calculation to make game playable, since reference assets in double obstacles are too big.
	// This value is fine tuned manually and should not be changed without a good reason.
	reference_scale_modifier    = 1.1325

	// NOTE: Reference screen resolution was provided by Igor and should not be changed without a good reason.
	reference_resolution_width  = int(math.round(87 * reference_scale_modifier))
	reference_resolution_height = int(math.round(179 * reference_scale_modifier))
)

// Green color defined by Igor. Should not be changed without his approval.
const background_color = gx.Color{
	r: 64
	g: 164
	b: 124
}

const (
	background_vine_image_name_template = 'background_vine_{0}.png'
)

// App stores the minimal data required for rendering the app, focusing on images and related data.
// Also, it stores the world model, which contains all game data.
pub struct App {
mut:
	graphical_context &gg.Context
	is_initialized    bool
	is_quited         bool
	images_scale      int

	chicken_idle_image gg.Image

	obstacle_section_right_image  gg.Image
	obstacle_endings_right_images []gg.Image
	obstacle_image_id_to_y_offset map[int]int

	egg_1_image gg.Image

	ecs_world &ecs.World
}

// create_app Creates and sets up graphical app.
pub fn create_app() &App {
	mut app := &App{
		graphical_context: unsafe { nil }
		ecs_world: &ecs.World{}
	}

	app.graphical_context = gg.new_context(
		bg_color: graphics.background_color
		width: graphics.window_width_pixels
		height: graphics.window_height_pixels
		create_window: true
		window_title: 'Eggcellent Adventure'
		ui_mode: true
		init_fn: initialize
		frame_fn: draw_frame
		quit_fn: quit
		event_fn: on_event
		user_data: app
	)

	return app
}

fn initialize(mut app App) {
	calculate_images_scale(mut app) or { panic(err) }
	load_assets(mut app) or { panic(err) }
	app.is_initialized = true
}

fn calculate_images_scale(mut app App) ! {
	screen_size := get_screen_size(app)

	app.images_scale = scale_factor.calculate_integer_scale_factor(graphics.reference_resolution_height,
		graphics.reference_resolution_width, screen_size.height, screen_size.width)!
}

fn draw_frame(mut app App) {
	app.graphical_context.begin()

	renderable_entities := ecs.get_entities_with_two_components[common.RenderingMetadata, common.Position](app.ecs_world) or {
		return
	}

	for entity in renderable_entities {
		position_component := ecs.get_component[common.Position](entity) or { continue }

		rendering_metadata_component := ecs.get_component[common.RenderingMetadata](entity) or {
			continue
		}

		app.graphical_context.draw_image_with_config(gg.DrawImageConfig{
			img_rect: gg.Rect{
				x: f32(position_component.x)
				y: f32(position_component.y)
				width: get_image_width_by_id(mut app, rendering_metadata_component.image_id)
				height: get_image_height_by_id(mut app, rendering_metadata_component.image_id)
			}
			flip_x: rendering_metadata_component.orientation == common.Orientation.left
			img_id: rendering_metadata_component.image_id
		})
	}

	app.graphical_context.end()
}

// get_obstacle_section_width Returns obstacle section width with scale applied.
pub fn get_obstacle_section_width(mut app App) int {
	return get_image_width_by_id(mut app, app.obstacle_section_right_image.id)
}

// get_obstacle_section_height Returns obstacle section height with scale applied.
pub fn get_obstacle_section_height(mut app App) int {
	return get_image_height_by_id(mut app, app.obstacle_section_right_image.id)
}

pub fn get_image_width_by_id(mut app App, image_id int) int {
	return get_image_by_id(mut app, image_id).width * app.images_scale
}

pub fn get_image_height_by_id(mut app App, image_id int) int {
	return get_image_by_id(mut app, image_id).height * app.images_scale
}

fn get_image_by_id(mut app App, image_id int) &gg.Image {
	return app.graphical_context.get_cached_image_by_idx(image_id)
}

fn quit(_ &gg.Event, mut app App) {
	app.is_quited = true
}

fn on_event(event &gg.Event, mut app App) {
	$if android {
		if event.typ == .touches_ended && event.num_touches == 1 {
			app.touched(event.touches)
		}
	} $else {
		if event.typ == .key_down {
			app.key_down(event.key_code)
		}
	}
}

fn (mut app App) touched(touches [8]gg.TouchPoint) {
	screen_width := get_screen_size(app).width

	if touches[0].pos_x > screen_width / 2 {
		ecs.execute_system_with_three_components[chicken.IsControlledByPlayerTag, common.RenderingMetadata, common.Velocity](app.ecs_world,
			chicken.player_control_system_right_touch) or { return }
	} else {
		ecs.execute_system_with_three_components[chicken.IsControlledByPlayerTag, common.RenderingMetadata, common.Velocity](app.ecs_world,
			chicken.player_control_system_left_touch) or { return }
	}
}

fn (mut app App) key_down(key gg.KeyCode) {
	match key {
		.right {
			ecs.execute_system_with_three_components[chicken.IsControlledByPlayerTag, common.RenderingMetadata, common.Velocity](app.ecs_world,
				chicken.player_control_system_right_touch) or { return }
		}
		.left {
			ecs.execute_system_with_three_components[chicken.IsControlledByPlayerTag, common.RenderingMetadata, common.Velocity](app.ecs_world,
				chicken.player_control_system_left_touch) or { return }
		}
		else {}
	}
}

// start_app Starts graphical app.
pub fn start_app(mut app App) {
	app.graphical_context.run()
}

// get_screen_size Returns screen size.
// ATTENTION!⚠ Right now for Android it returns the window size (since on Android window is the full screen, so it's the same as screen size).
pub fn get_screen_size(app App) gg.Size {
	return app.graphical_context.window_size()
}

// is_initialized Checks if graphical app is initialized (`initialize()` function was called).
pub fn is_initialized(app App) bool {
	return app.is_initialized
}

// is_quited Checks if graphical app is quited (`quit()` function was called).
pub fn is_quited(app App) bool {
	return app.is_quited
}

// invoke_frame_draw Invokes frame draw (only should be used if `ui_mode` is set to `true`).
pub fn invoke_frame_draw(mut app App) {
	app.graphical_context.refresh_ui()
}

// get_obstacle_section_right_image_id Returns obstacle section right image id.
pub fn get_obstacle_section_right_image_id(app App) int {
	return app.obstacle_section_right_image.id
}

// get_obstacle_endings Returns obstacle endings.
pub fn get_obstacle_endings(mut app App) []world.ObstacleEnding {
	return app.obstacle_endings_right_images.map(create_obstacle_ending(mut app, it.id))
}

fn create_obstacle_ending(mut app App, image_id int) world.ObstacleEnding {
	return world.ObstacleEnding{
		image_id: image_id
		y_offset: app.obstacle_image_id_to_y_offset[image_id]
		width: get_image_width_by_id(mut app, image_id)
		height: get_image_height_by_id(mut app, image_id)
	}
}

pub fn get_ecs_world(app App) &ecs.World {
	return app.ecs_world
}

pub fn get_chicken_idle_image_id(app App) int {
	return app.chicken_idle_image.id
}

pub fn get_egg_1_image_id(app App) int {
	return app.egg_1_image.id
}
