module graphics

import gg
import os
import common

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
	chicken_frames_count = 5
	egg_frames_count     = 6
)

fn load_assets(mut app App) ! {
	right_obstacle_assets_path := common.get_platform_dependent_asset_path('obstacle/right')
	load_images_right_obstacle_images(mut app, right_obstacle_assets_path)!

	for chicken_frame_count in 0 .. graphics.chicken_frames_count {
		chicken_frame_asset_path := common.get_platform_dependent_asset_path('chicken/chicken_flight_${
			chicken_frame_count + 1}.png')

		app.chicken_animation_frames << load_image(mut app, chicken_frame_asset_path)!
	}

	for egg_frame_count in 0 .. graphics.egg_frames_count {
		egg_frame_asset_path := common.get_platform_dependent_asset_path('egg/egg_${
			egg_frame_count + 1}.png')

		app.egg_animation_frames << load_image(mut app, egg_frame_asset_path)!
	}

	app.side_obstacle_right_image = load_image(mut app, common.get_platform_dependent_asset_path('obstacle/side/side_obstacle_right.png'))!
	app.bottom_obstacle_image = load_image(mut app, common.get_platform_dependent_asset_path('obstacle/bottom/bottom_obstacle.png'))!

	app.menu_background_image = load_image(mut app, common.get_platform_dependent_asset_path('menu/background.png'))!
	app.menu_cannon_image = load_image(mut app, common.get_platform_dependent_asset_path('menu/cannon.png'))!
	app.menu_grass_image = load_image(mut app, common.get_platform_dependent_asset_path('menu/grass.png'))!
	app.menu_start_game_button = load_image(mut app, common.get_platform_dependent_asset_path('menu/ui/start_game_button.png'))!
}

fn load_images_right_obstacle_images(mut app App, root_path string) ! {
	app.obstacle_section_right_image = load_image(mut app, os.join_path_single(root_path,
		graphics.obstacle_section_right_image_name))!

	ending_images_names := [
		graphics.obstacle_ending_simple_right_image_name,
		graphics.obstacle_ending_closed_bud_up_right_image_name,
		graphics.obstacle_ending_closed_bud_down_right_image_name,
		graphics.obstacle_ending_bud_right_image_name,
		graphics.obstacle_ending_bud_eye_right_image_name,
	]

	app.obstacle_endings_right_images = ending_images_names.map(load_image_and_bind_offset(mut app,
		root_path, it)!)
}

fn load_image_and_bind_offset(mut app App, root_path string, image_name string) !gg.Image {
	image := load_image(mut app, os.join_path_single(root_path, image_name))!
	app.obstacle_image_id_to_y_offset[image.id] = graphics.obstacle_ending_image_name_to_y_offset_map[image_name] * app.images_scale

	return image
}

fn load_image(mut app App, path string) !gg.Image {
	return app.graphical_context.create_image(path)
}
