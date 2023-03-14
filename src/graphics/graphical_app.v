// This file implements graphical app, that manages all graphical things like window, rendering, etc.

module graphics

import gg
import gx
import os

// Window sie on Android works a bit like changing DPI, since app in the full screen mode all the time.
// For now I just set it to half of the my phone's screen size (Xiaomi Mi 10T).
const (
	window_width_pixels  = 540
	window_height_pixels = 1200
)

// Store as low as possible data here, ideally only things that are needed for rendering (like images).
struct GraphicalApp {
mut:
	graphical_context &gg.Context
	obstacle_image    gg.Image
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
		init_fn: load_assets
		frame_fn: draw_frame
		user_data: app
	)

	return app
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
	draw_obstacle(app)
	app.graphical_context.end()
}

fn draw_obstacle(app GraphicalApp) {
	scale_multiplier := 5
	app.graphical_context.draw_image(0, 0, app.obstacle_image.width * scale_multiplier,
		app.obstacle_image.height * scale_multiplier, app.obstacle_image)
}

// start_app Starts graphical app.
pub fn start_app(mut app GraphicalApp) {
	app.graphical_context.run()
}
