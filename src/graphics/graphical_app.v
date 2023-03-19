// This file implements graphical app, that manages all graphical things like window, rendering, etc.

module graphics

import gg
import gx
import os
import obstacle
import world

// Window sie on Android works a bit like changing DPI, since app in the full screen mode all the time.
// For now I just set it to half of the my phone's screen size (Xiaomi Mi 10T).
const (
	window_width_pixels  = 540
	window_height_pixels = 1200
)

// Store as low as possible data here, ideally only things that are needed for rendering (like images).
pub struct GraphicalApp {
mut:
	graphical_context &gg.Context
	obstacle_image    gg.Image
	world_model       world.Model
	is_initialized    bool
	is_quited         bool
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
		obstacle_image := os.read_apk_asset('obstacle/left/obstacle_section_left.png') or {
			panic(err)
		}

		app.obstacle_image = app.graphical_context.create_image_from_byte_array(obstacle_image)
	} $else {
		app.obstacle_image = app.graphical_context.create_image(os.resource_abs_path('../assets/obstacle/left/obstacle_section_left.png'))
	}
}

fn draw_frame(app &GraphicalApp) {
	app.graphical_context.begin()

	for obstacle_position in app.world_model.obstacle_positions {
		draw_obstacle(app, obstacle_position)
	}

	app.graphical_context.end()
}

fn draw_obstacle(app GraphicalApp, position obstacle.Position) {
	app.graphical_context.draw_image(position.x, position.y, get_obstacle_section_width(app),
		app.obstacle_image.height * 5, app.obstacle_image)
}

pub fn get_obstacle_section_width(app GraphicalApp) int {
	scale_multiplier := 5
	return app.obstacle_image.width * scale_multiplier
}

fn quit(_ &gg.Event, mut app GraphicalApp) {
	app.is_quited = true
}

// start_app Starts graphical app.
pub fn start_app(mut app GraphicalApp) {
	app.graphical_context.run()
}

pub fn get_screen_size(app GraphicalApp) gg.Size {
	return app.graphical_context.window_size()
}

pub fn update_model(mut app GraphicalApp, new_model world.Model) {
	app.world_model = new_model
}

pub fn trigger_frame_draw(mut app GraphicalApp) {
	app.graphical_context.refresh_ui()
}

pub fn is_initialized(app GraphicalApp) bool {
	return app.is_initialized
}

pub fn is_quited(app GraphicalApp) bool {
	return app.is_quited
}
