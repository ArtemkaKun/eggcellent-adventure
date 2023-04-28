module world

import os
import json

pub struct BackgroundVineConfigParameters {
pub:
	shift_from_left_side_pixels int
	moving_speed_modifier       f64
}

pub fn get_background_vines_config() ![]BackgroundVineConfigParameters {
	$if android {
		file_content := os.read_apk_asset('configs/background_vines_config.json')!

		return json.decode([]BackgroundVineConfigParameters, file_content.bytestr())!
	} $else {
		file_content := os.read_file(os.resource_abs_path('/assets/configs/background_vines_config.json'))!

		return json.decode([]BackgroundVineConfigParameters, file_content)!
	}
}
