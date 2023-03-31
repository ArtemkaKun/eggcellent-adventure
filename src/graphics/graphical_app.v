// This file implements graphical app, that manages all graphical things like window, rendering, etc.

module graphics

import gg
import gx
import os
import world
import obstacle

// Window size on Android works a bit like changing DPI, since app in the full screen mode all the time.
// For now I just set it to half of the my phone's screen size (Xiaomi Mi 10T).
const (
	window_width_pixels                              = 540
	window_height_pixels                             = 1200
	obstacle_block_scale                             = 5 // NOTE: scale set to 5 for now, since it's the only one that looks good. It should be measured in the future to make sure all elements look harmonious.

	obstacle_section_right_image_path                = '/obstacle_section_right.png'
	obstacle_ending_simple_right_image_path          = '/obstacle_ending_simple_right.png'
	obstacle_ending_closed_bud_up_right_image_path   = '/obstacle_ending_closed_bud_up_right.png'
	obstacle_ending_closed_bud_down_right_image_path = '/obstacle_ending_closed_bud_down_right.png'
	obstacle_ending_bud_right_image_path             = '/obstacle_ending_bud_right.png'
	obstacle_ending_bud_eye_right_image_path         = '/obstacle_ending_bud_eye_right.png'
)

// Store as low as possible data here, ideally only things that are needed for rendering (like images).
pub struct GraphicalApp {
mut:
	graphical_context             &gg.Context
	obstacle_section_right_image  gg.Image
	obstacle_endings_right_images []gg.Image
	world_model                   world.WorldModel
	is_initialized                bool
	is_quited                     bool
}

// create_app Creates and sets up graphical app.
pub fn create_app() &GraphicalApp {
	mut app := &GraphicalApp{
		graphical_context: unsafe { nil }
	}

	app.graphical_context = gg.new_context(
		bg_color: gx.white
		width: graphics.window_width_pixels
		height: graphics.window_height_pixels
		create_window: true
		window_title: 'Eggcellent Adventure'
		ui_mode: true
		init_fn: initialize
		frame_fn: draw_frame
		quit_fn: quit
		user_data: app
	)

	return app
}

fn initialize(mut app GraphicalApp) {
	load_assets(mut app)
	app.is_initialized = true
}

fn load_assets(mut app GraphicalApp) {
	// The game will only be used on Android, but be able to run it on PC will speed up development.
	$if android {
		root_right_obstacle_path := 'obstacle/right'
		load_images(mut app, root_right_obstacle_path, load_android_image_from_path)
	} $else {
		root_right_obstacle_path := '/assets/obstacle/right'
		load_images(mut app, root_right_obstacle_path, load_pc_image_from_path)
	}
}

fn load_images(mut app GraphicalApp, root_path string, load_image_function fn (mut GraphicalApp, string) gg.Image) {
	app.obstacle_section_right_image = load_image_function(mut app, root_path +
		graphics.obstacle_section_right_image_path)

	app.obstacle_endings_right_images = [
		load_image_function(mut app, root_path + graphics.obstacle_ending_simple_right_image_path),
		load_image_function(mut app, root_path +
			graphics.obstacle_ending_closed_bud_up_right_image_path),
		load_image_function(mut app, root_path +
			graphics.obstacle_ending_closed_bud_down_right_image_path),
		load_image_function(mut app, root_path + graphics.obstacle_ending_bud_right_image_path),
		load_image_function(mut app, root_path + graphics.obstacle_ending_bud_eye_right_image_path),
	]
}

fn load_android_image_from_path(mut app GraphicalApp, path string) gg.Image {
	$if android {
		image := os.read_apk_asset(path) or { panic(err) }

		return app.graphical_context.create_image_from_byte_array(image)
	} $else {
		return gg.Image{}
	}
}

fn load_pc_image_from_path(mut app GraphicalApp, path string) gg.Image {
	$if !android {
		return app.graphical_context.create_image(os.resource_abs_path(path))
	} $else {
		return gg.Image{}
	}
}

fn draw_frame(app &GraphicalApp) {
	app.graphical_context.begin()

	for obstacle in app.world_model.obstacles {
		for section in obstacle {
			draw_obstacle_section(app, section)
		}
	}

	app.graphical_context.end()
}

fn draw_obstacle_section(app GraphicalApp, obstacle_section obstacle.ObstacleSection) {
	app.graphical_context.draw_image_with_config(gg.DrawImageConfig{
		img_rect: gg.Rect{
			x: f32(obstacle_section.position.x)
			y: f32(obstacle_section.position.y)
			width: get_obstacle_section_width(app)
			height: get_obstacle_section_height(app)
		}
		flip_x: obstacle_section.orientation == obstacle.Orientation.left
		img_id: obstacle_section.image_id
	})
}

// get_obstacle_section_width Returns obstacle section width with scale applied.
pub fn get_obstacle_section_width(app GraphicalApp) int {
	return app.obstacle_section_right_image.width * graphics.obstacle_block_scale
}

// get_obstacle_section_height Returns obstacle section height with scale applied.
pub fn get_obstacle_section_height(app GraphicalApp) int {
	return app.obstacle_section_right_image.height * graphics.obstacle_block_scale
}

fn quit(_ &gg.Event, mut app GraphicalApp) {
	app.is_quited = true
}

// start_app Starts graphical app.
pub fn start_app(mut app GraphicalApp) {
	app.graphical_context.run()
}

// get_screen_size Returns screen size.
// ATTENTION!⚠ Right now for Android it returns the window size (since on Android window is the full screen, so it's the same as screen size).
pub fn get_screen_size(app GraphicalApp) gg.Size {
	return app.graphical_context.window_size()
}

// update_world_model Updates world model structure in the GraphicalApp structure.
// ATTENTION!⚠ It assigns new structure to the GraphicalApp, not modifies the existing one.
pub fn update_world_model(mut app GraphicalApp, new_model world.WorldModel) {
	app.world_model = new_model
}

// is_initialized Checks if graphical app is initialized (`initialize()` function was called).
pub fn is_initialized(app GraphicalApp) bool {
	return app.is_initialized
}

// is_quited Checks if graphical app is quited (`quit()` function was called).
pub fn is_quited(app GraphicalApp) bool {
	return app.is_quited
}

// get_world_model Returns world model structure from the GraphicalApp structure.
pub fn get_world_model(app GraphicalApp) world.WorldModel {
	return app.world_model
}

// invoke_frame_draw Invokes frame draw (only should be used if `ui_mode` is set to `true`).
pub fn invoke_frame_draw(mut app GraphicalApp) {
	app.graphical_context.refresh_ui()
}

pub fn get_obstacle_section_right_image_id(app GraphicalApp) int {
	return app.obstacle_section_right_image.id
}
