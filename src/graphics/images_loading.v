module graphics

import gg
import os
import common

fn load_assets(mut app App) ! {
	right_obstacle_assets_path := common.get_platform_dependent_asset_path('obstacle/right')
	chicken_idle_asset_path := common.get_platform_dependent_asset_path('chicken/chicken_idle.png')
	egg_1_asset_path := common.get_platform_dependent_asset_path('egg/egg_1.png')

	load_images_right_obstacle_images(mut app, right_obstacle_assets_path)!
	app.chicken_idle_image = load_image(mut app, chicken_idle_asset_path)!
	app.egg_1_image = load_image(mut app, egg_1_asset_path)!
}

fn load_images_right_obstacle_images(mut app App, root_path string) ! {
	app.obstacle_section_right_image = load_image(mut app, os.join_path_single(root_path,
		obstacle_section_right_image_name))!

	ending_images_names := [
		obstacle_ending_simple_right_image_name,
		obstacle_ending_closed_bud_up_right_image_name,
		obstacle_ending_closed_bud_down_right_image_name,
		obstacle_ending_bud_right_image_name,
		obstacle_ending_bud_eye_right_image_name,
	]

	app.obstacle_endings_right_images = ending_images_names.map(load_image_and_bind_offset(mut app,
		root_path, it)!)
}

fn load_image_and_bind_offset(mut app App, root_path string, image_name string) !gg.Image {
	image := load_image(mut app, os.join_path_single(root_path, image_name))!
	app.obstacle_image_id_to_y_offset[image.id] = obstacle_ending_image_name_to_y_offset_map[image_name] * app.images_scale

	return image
}

fn load_image(mut app App, path string) !gg.Image {
	$if android {
		image := os.read_apk_asset(path)!

		return app.graphical_context.create_image_from_byte_array(image)
	} $else {
		return app.graphical_context.create_image(path)
	}
}
