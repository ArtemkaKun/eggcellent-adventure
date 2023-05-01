module graphics

import gg
import os
import background_vines
import common

fn load_assets(mut app App) ! {
	right_obstacle_assets_path := common.get_platform_dependent_asset_part('obstacle/right')
	background_vines_assets_path := common.get_platform_dependent_asset_part('background/vines')

	// The game will only be used on Android, but be able to run it on PC will speed up development.
	$if android {
		load_images_right_obstacle_images(mut app, load_image_on_android, right_obstacle_assets_path)!

		for background_vine_id in 1 .. background_vines.max_background_vines_id {
			app.background_vine_images << load_image_on_android(mut app, os.join_path_single(background_vines_assets_path,
				background_vine_image_name_template.replace('{0}', background_vine_id.str())))!
		}
	} $else {
		load_images_right_obstacle_images(mut app, load_image_on_pc, right_obstacle_assets_path)!

		for background_vine_id in 1 .. background_vines.max_background_vines_id {
			app.background_vine_images << load_image_on_pc(mut app, os.join_path_single(background_vines_assets_path,
				background_vine_image_name_template.replace('{0}', background_vine_id.str())))!
		}
	}
}

fn load_images_right_obstacle_images(mut app App, load_image_function fn (mut App, string) !gg.Image, root_path string) ! {
	app.obstacle_section_right_image = load_image_function(mut app, os.join_path_single(root_path,
		obstacle_section_right_image_name))!

	ending_images_names := [
		obstacle_ending_simple_right_image_name,
		obstacle_ending_closed_bud_up_right_image_name,
		obstacle_ending_closed_bud_down_right_image_name,
		obstacle_ending_bud_right_image_name,
		obstacle_ending_bud_eye_right_image_name,
	]

	app.obstacle_endings_right_images = ending_images_names.map(load_image_and_bind_offset(mut app,
		load_image_function, root_path, it)!)
}

fn load_image_and_bind_offset(mut app App, load_image_function fn (mut App, string) !gg.Image, root_path string, image_name string) !gg.Image {
	image := load_image_function(mut app, os.join_path_single(root_path, image_name))!
	app.obstacle_image_id_to_y_offset[image.id] = obstacle_ending_image_name_to_y_offset_map[image_name] * app.images_scale

	return image
}

fn load_image_on_android(mut app App, path string) !gg.Image {
	$if android {
		image := os.read_apk_asset(path) or { panic(err) }

		return app.graphical_context.create_image_from_byte_array(image)
	} $else {
		return error('Unsupported platform!')
	}
}

fn load_image_on_pc(mut app App, path string) !gg.Image {
	$if !android {
		return app.graphical_context.create_image(path)
	} $else {
		return error('Unsupported platform!')
	}
}
