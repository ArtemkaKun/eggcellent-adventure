// This file implements graphical app, that manages all graphical things like window, rendering, etc.

module graphics

import gg
import gx
import scale_factor
import math
import ecs
import common
import player_input
import obstacle
import collision

// NOTE:
// Window size on Android works a bit like changing DPI, since app in the full screen mode all the time.
// For now I just set it to half of the my phone's screen size (Xiaomi Mi 10T).
const (
	window_width_pixels  = 540
	window_height_pixels = 1200
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

// App stores the minimal data required for rendering the app, focusing on images and related data.
// Also, it stores the ECS world structure.
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

// create_app creates and sets up graphical app.
pub fn create_app(ecs_world &ecs.World) &App {
	mut app := &App{
		graphical_context: unsafe { nil }
		ecs_world: ecs_world
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
		event_fn: react_on_input_event
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

	query := ecs.query_for_two_components[ecs.RenderData, ecs.Position]
	renderable_entities := ecs.get_entities_with_query(app.ecs_world, query)

	for entity in renderable_entities {
		draw_entity(mut app, entity)
	}

	app.graphical_context.end()
}

fn draw_entity(mut app App, entity ecs.Entity) {
	// NOTE: return will never be reached here, since the query function guarantees that the entity has both components.
	position_component := ecs.get_entity_component[ecs.Position](entity) or { return }
	rendering_metadata_component := ecs.get_entity_component[ecs.RenderData](entity) or { return }

	image_id := rendering_metadata_component.image_id

	app.graphical_context.draw_image_with_config(gg.DrawImageConfig{
		img_rect: gg.Rect{
			x: f32(position_component.x)
			y: f32(position_component.y)
			width: get_image_width_by_id(mut app, image_id)
			height: get_image_height_by_id(mut app, image_id)
		}
		flip_x: rendering_metadata_component.orientation == common.Orientation.left
		img_id: image_id
	})

	// TODO: debug code, under debug flag
	collider_component := ecs.get_entity_component[collision.Collider](entity) or { return }

	app.graphical_context.draw_rect_empty(f32(position_component.x), f32(position_component.y),
		f32(collider_component.width), f32(collider_component.height), gx.Color{ r: 255, g: 0, b: 0 })
}

// get_image_width_by_id retrieves the width of the image with the specified image_id.
// The returned width is scaled to current application scale factor.
pub fn get_image_width_by_id(mut app App, image_id int) int {
	return get_image_by_id(mut app, image_id).width * app.images_scale
}

// get_image_height_by_id retrieves the height of the image with the specified image_id.
// The returned height is scaled to current application scale factor.
pub fn get_image_height_by_id(mut app App, image_id int) int {
	return get_image_by_id(mut app, image_id).height * app.images_scale
}

fn get_image_by_id(mut app App, image_id int) &gg.Image {
	return app.graphical_context.get_cached_image_by_idx(image_id)
}

fn quit(_ &gg.Event, mut app App) {
	app.is_quited = true
}

fn react_on_input_event(event &gg.Event, mut app App) {
	player_input.react_on_input_event(event, app.ecs_world, get_screen_size(app).width)
}

// start_app starts graphical app.
pub fn start_app(mut app App) {
	app.graphical_context.run()
}

// get_screen_size returns screen size.
// ATTENTION!⚠ Right now for Android it returns the window size (since on Android window is the full screen, so it's the same as screen size).
pub fn get_screen_size(app App) gg.Size {
	return app.graphical_context.window_size()
}

// is_initialized checks if graphical app is initialized (`initialize()` function was called).
pub fn is_initialized(app App) bool {
	return app.is_initialized
}

// is_quited checks if graphical app is quited (`quit()` function was called).
pub fn is_quited(app App) bool {
	return app.is_quited
}

// invoke_frame_draw invokes frame draw (only should be used if `ui_mode` is set to `true`).
pub fn invoke_frame_draw(mut app App) {
	app.graphical_context.refresh_ui()
}

// get_obstacle_section_right_image_id returns obstacle section right image id.
pub fn get_obstacle_section_right_image_id(app App) int {
	return app.obstacle_section_right_image.id
}

// get_obstacle_endings_render_data returns obstacle endings.
pub fn get_obstacle_endings_render_data(mut app App) []obstacle.ObstacleEndingRenderData {
	return app.obstacle_endings_right_images.map(create_obstacle_ending_render_data(mut app,
		it.id))
}

fn create_obstacle_ending_render_data(mut app App, image_id int) obstacle.ObstacleEndingRenderData {
	return obstacle.ObstacleEndingRenderData{
		image_id: image_id
		y_offset: app.obstacle_image_id_to_y_offset[image_id]
		width: get_image_width_by_id(mut app, image_id)
		height: get_image_height_by_id(mut app, image_id)
	}
}

// get_chicken_idle_image_id returns chicken idle image id.
pub fn get_chicken_idle_image_id(app App) int {
	return app.chicken_idle_image.id
}

// get_egg_1_image_id returns egg 1 image id.
pub fn get_egg_1_image_id(app App) int {
	return app.egg_1_image.id
}
