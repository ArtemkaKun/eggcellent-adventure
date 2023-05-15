// This file contains implementation of background vines config. Config can help to edit parameters of
// background vines without recompilation of the game (so Igor can edit things easily).

module background_vines

import os
import json
import common

// BackgroundVineConfigParameters This structure defines config parameters for one background vine.
// - id -> ID of the background vine. This ID must be unique for each background vine. This ID must represents the order of the background vine in the game (so closer background vines must have smaller IDs).
// - x_offset_reference_pixels -> Offset of the background vine from the left edge of screen in pixels. This values must be based on reference resolution of the screen, on which the game was designed.
// - moving_speed_modifier -> This value defines how fast the background vine will move. This value must be in range from 0 to 1. This value defines background vine speed relative to obstacles speed.
pub struct BackgroundVineConfigParameters {
pub:
	id                        int [required]
	x_offset_reference_pixels int [required]
	moving_speed_modifier     f64 [required]
}

const for_background_vine_error_message_part = 'for background vine with ID {0}'

// get_background_vines_config This function returns config parameters for background vines.
pub fn get_background_vines_config() ![]BackgroundVineConfigParameters {
	background_vines_config_file_path := common.get_platform_dependent_asset_part('configs/background_vines_config.json')
	file_content := read_background_vines_config_file(background_vines_config_file_path)!

	config_parameters := json.decode([]BackgroundVineConfigParameters, file_content)!
	validate_background_vines_config(config_parameters)!

	return config_parameters
}

fn read_background_vines_config_file(path string) !string {
	$if android {
		file_content := os.read_apk_asset(path)!

		return file_content.bytestr()
	} $else {
		return os.read_file(path)!
	}
}

fn validate_background_vines_config(config_parameters []BackgroundVineConfigParameters) ! {
	validate_config_parameters_count(config_parameters.len)!

	for background_vine_index in 1 .. max_background_vines_id {
		check_if_all_config_parameters_exist(config_parameters, background_vine_index)!
	}

	for background_vine_config in config_parameters {
		validate_config_parameters_values(background_vine_config, config_parameters)!
	}
}

fn validate_config_parameters_count(config_parameters_count int) ! {
	if config_parameters_count < background_vines_count {
		return error('Not all background vines are configured! There must be ${background_vines_count} objects with parameters in the config file.')
	}

	if config_parameters_count > background_vines_count {
		return error('Too many background objects with parameters in the config file! Max allowed count is ${background_vines_count}.')
	}
}

fn check_if_all_config_parameters_exist(config_parameters []BackgroundVineConfigParameters, background_vine_index int) ! {
	if config_parameters.any(it.id == background_vine_index) == false {
		return error('Config object is missing ${create_for_background_vine_error_message_part(background_vine_index)}')
	}
}

fn validate_config_parameters_values(background_vine_config BackgroundVineConfigParameters, config_parameters []BackgroundVineConfigParameters) ! {
	validate_background_vine_id_uniqueness(background_vine_config, config_parameters)!
	validate_moving_speed_modifier(background_vine_config)!
}

fn validate_background_vine_id_uniqueness(background_vine_config BackgroundVineConfigParameters, config_parameters []BackgroundVineConfigParameters) ! {
	current_background_vine_id := background_vine_config.id

	if config_parameters.filter(it.id == current_background_vine_id).len > 1 {
		return error('Config object is duplicated ${create_for_background_vine_error_message_part(current_background_vine_id)}')
	}
}

fn validate_moving_speed_modifier(background_vine_config BackgroundVineConfigParameters) ! {
	error_message_part := 'moving_speed_modifier value ${create_for_background_vine_error_message_part(background_vine_config.id)}'

	if background_vine_config.moving_speed_modifier < 0 {
		return error('${error_message_part} is lower than 0! This has no sense because this will make background vines move up, while they must move down.')
	}

	if background_vine_config.moving_speed_modifier.eq_epsilon(0) {
		return error('${error_message_part} equals 0! This has no sense because this will make background vines static (they will not move).')
	}

	if background_vine_config.moving_speed_modifier.eq_epsilon(1) {
		return error('${error_message_part} equals 1! Since background movement speed depends on obstacles movement speed, setting moving_speed_modifier parameter to 1 will make background obstacles move with the same speed as obstacles, and this will break the parallax effect.')
	}

	if background_vine_config.moving_speed_modifier > 1 {
		return error('${error_message_part} is bigger than 1! Since background movement speed depends on obstacles movement speed, setting moving_speed_modifier parameter to be bigger than 1 will make background obstacles move faster than obstacles, and this will break the parallax effect.')
	}
}

fn create_for_background_vine_error_message_part(background_vine_id int) string {
	return background_vines.for_background_vine_error_message_part.replace('{0}', background_vine_id.str())
}
