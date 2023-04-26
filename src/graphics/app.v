// This file implements graphical app, that manages all graphical things like window, rendering, etc.

module graphics

import gg
import gx
import world
import obstacle
import scale_factor
import math

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
	background_vine_1_image_name = 'background_vine_1.png'
)

// App stores the minimal data required for rendering the app, focusing on images and related data.
// Also, it stores the world model, which contains all game data.
pub struct App {
mut:
	graphical_context &gg.Context
	is_initialized    bool
	is_quited         bool
	images_scale      int

	obstacle_section_right_image  gg.Image
	obstacle_endings_right_images []gg.Image
	obstacle_image_id_to_y_offset map[int]int

	background_vine_1_image gg.Image

	world_model world.WorldModel
}

// create_app Creates and sets up graphical app.
pub fn create_app() &App {
	mut app := &App{
		graphical_context: unsafe { nil }
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

	// First draw vines to control Z because normal Z is bugged
	for background_vine in app.world_model.background_vines {
		for vine in background_vine {
			app.graphical_context.draw_image_by_id(f32(vine.position.x), f32(vine.position.y),
				get_image_width_by_id(mut app, vine.image_id), get_image_height_by_id(mut app,
				vine.image_id), vine.image_id)
		}
	}

	for obstacle in app.world_model.obstacles {
		for section in obstacle {
			draw_obstacle_section(mut app, section)
		}
	}

	app.graphical_context.end()
}

fn draw_obstacle_section(mut app App, obstacle_section obstacle.ObstacleSection) {
	mut x_offset := 0
	image_width := get_image_width_by_id(mut app, obstacle_section.image_id)

	// NOTE:
	// When performing calculations, the obstacle section width image is used, but the width of the endings differs.
	// For the left orientation, the ending's position is right next to the edge of the previous section block,
	// so no adjustment is needed.
	// However, for the right orientation, we must offset the ending image by the difference
	// between the ending image width and the obstacle section width.
	// Consequently, for left orientation, images are drawn from the screen edge to the center, while for right orientation,
	// images are drawn from the center to the screen edge.
	if obstacle_section.orientation == obstacle.Orientation.right {
		x_offset = get_obstacle_section_width(mut app) - image_width
	}

	app.graphical_context.draw_image_with_config(gg.DrawImageConfig{
		img_rect: gg.Rect{
			x: f32(obstacle_section.position.x) + x_offset
			y: f32(obstacle_section.position.y)
			width: image_width
			height: get_image_height_by_id(mut app, obstacle_section.image_id)
		}
		flip_x: obstacle_section.orientation == obstacle.Orientation.left
		img_id: obstacle_section.image_id
	})
}

// get_obstacle_section_width Returns obstacle section width with scale applied.
pub fn get_obstacle_section_width(mut app App) int {
	return get_image_width_by_id(mut app, app.obstacle_section_right_image.id)
}

// get_obstacle_section_height Returns obstacle section height with scale applied.
pub fn get_obstacle_section_height(mut app App) int {
	return get_image_height_by_id(mut app, app.obstacle_section_right_image.id)
}

fn get_image_width_by_id(mut app App, image_id int) int {
	return get_image_by_id(mut app, image_id).width * app.images_scale
}

fn get_image_height_by_id(mut app App, image_id int) int {
	return get_image_by_id(mut app, image_id).height * app.images_scale
}

fn get_image_by_id(mut app App, image_id int) &gg.Image {
	return app.graphical_context.get_cached_image_by_idx(image_id)
}

fn quit(_ &gg.Event, mut app App) {
	app.is_quited = true
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

// update_world_model Updates world model structure in the GraphicalApp structure.
pub fn update_world_model(mut app App, new_model world.WorldModel) {
	app.world_model = new_model
}

// is_initialized Checks if graphical app is initialized (`initialize()` function was called).
pub fn is_initialized(app App) bool {
	return app.is_initialized
}

// is_quited Checks if graphical app is quited (`quit()` function was called).
pub fn is_quited(app App) bool {
	return app.is_quited
}

// get_world_model Returns world model structure from the GraphicalApp structure.
pub fn get_world_model(app App) world.WorldModel {
	return app.world_model
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
pub fn get_obstacle_endings(app App) []world.ObstacleEnding {
	return app.obstacle_endings_right_images.map(create_obstacle_ending(app, it.id))
}

fn create_obstacle_ending(app App, image_id int) world.ObstacleEnding {
	return world.ObstacleEnding{
		image_id: image_id
		y_offset: app.obstacle_image_id_to_y_offset[image_id]
	}
}

pub fn get_background_vine_1_image_id(app App) int {
	return app.background_vine_1_image.id
}

pub fn get_background_vine_1_height(mut app App) int {
	return get_image_height_by_id(mut app, app.background_vine_1_image.id)
}
