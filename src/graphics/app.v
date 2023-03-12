module graphics

import gg
import gx
import os

const (
	window_width  = 540
	window_height = 1200
)

struct App {
mut:
	graphical_context &gg.Context
	obstacle_image    gg.Image
}

pub fn create_app() &App {
	mut app := &App{
		graphical_context: unsafe { nil }
	}

	app.graphical_context = gg.new_context(
		bg_color: gx.white
		width: graphics.window_width
		height: graphics.window_height
		create_window: true
		window_title: 'Eggcellent Adventure'
		init_fn: load_images
		frame_fn: frame
		user_data: app
	)

	return app
}

fn load_images(mut app App) {
	$if android {
		obstacle_image := os.read_apk_asset('obstacle/left/obstacle_section_left.png') or {
			panic(err)
		}

		app.obstacle_image = app.graphical_context.create_image_from_byte_array(obstacle_image)
	} $else {
		app.obstacle_image = app.graphical_context.create_image(os.resource_abs_path('../assets/obstacle/left/obstacle_section_left.png'))
	}
}

fn frame(app &App) {
	app.graphical_context.begin()
	draw(app)
	app.graphical_context.end()
}

fn draw(app App) {
	app.graphical_context.draw_image(0, 0, app.obstacle_image.width * 5, app.obstacle_image.height * 5,
		app.obstacle_image)
}

pub fn run(mut app App) {
	app.graphical_context.run()
}
