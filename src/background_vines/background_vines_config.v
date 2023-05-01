// This file contains implementation of background vines config. Config can help to edit parameters of
// background vines without recompilation of the game (so Igor can edit things easily).

module background_vines

import os
import json
import common

pub struct BackgroundVineConfigParameters {
pub:
	id                        int [required]
	x_offset_reference_pixels int [required]
	moving_speed_modifier     f64 [required]
}

pub fn get_background_vines_config() ![]BackgroundVineConfigParameters {
	background_vines_config_file_path := common.get_platform_dependent_asset_part('configs/background_vines_config.json')
	file_content := read_background_vines_config_file(background_vines_config_file_path)!

	config := json.decode([]BackgroundVineConfigParameters, file_content)!
	validate_background_vines_config(config)!

	return config
}

fn read_background_vines_config_file(path string) !string {
	$if android {
		file_content := os.read_apk_asset(path)!

		return file_content.bytestr()
	} $else {
		return os.read_file(path)!
	}
}

fn validate_background_vines_config(config []BackgroundVineConfigParameters) ! {
	if config.len < background_vines_count {
		return error('Not all background vines are configured! There must be ${background_vines_count} objects with parameters in config file.')
	}

	if config.len > background_vines_count {
		return error('Too many background objects with parameter in config file! Max allowed count is ${background_vines_count}.')
	}

	for background_vine_index in 1 .. max_background_vines_id {
		if config.any(it.id == background_vine_index) {
			continue
		} else {
			return error('Config object is missing for background vine with ID ${background_vine_index}')
		}
	}

	for background_vine_config in config {
		current_background_vine_id := background_vine_config.id

		if config.filter(it.id == current_background_vine_id).len > 1 {
			return error('Config object is duplicated for background vine with ID ${current_background_vine_id}')
		}

		if background_vine_config.x_offset_reference_pixels < 0 {
			return error('x_offset_reference_pixels value for background vine with ID ${current_background_vine_id} is lower than 0! 
			This has no sense because this can make a background vine invisible. Use 0 or higher value for this parameter.')
		}

		if background_vine_config.moving_speed_modifier < 0 {
			return error('moving_speed_modifier value for background vine with ID ${current_background_vine_id} is lower than 0!
			This has no sense because this will make background vines move up, while they must move down.')
		}

		if background_vine_config.moving_speed_modifier.eq_epsilon(0) {
			return error('moving_speed_modifier value for background vine with ID ${current_background_vine_id} equals 0!
			This has no sense because this will make background vines static (they will no move).')
		}

		if background_vine_config.moving_speed_modifier.eq_epsilon(1) {
			return error('moving_speed_modifier value for background vine with ID ${current_background_vine_id} equals 1!
			Since background movement speed depends on obstacles movement speed, setting moving_speed_modifier parameter
			to 1 will make background obstacle to move with the same speed as obstacles, and this will break parallax effect.')
		}

		if background_vine_config.moving_speed_modifier > 1 {
			return error('moving_speed_modifier value for background vine with ID ${current_background_vine_id} is bigger than 1!
			Since background movement speed depends on obstacles movement speed, setting moving_speed_modifier parameter
			to be bigger than 1 will make background obstacle to move faster than obstacles obstacles, and this will break parallax effect.')
		}
	}
}
