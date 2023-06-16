module common

import os

// NOTE: assets must always be in the `assets` folder, so all runtime resources, that game is needed,
// are in the one place. This value must stay the same all time.
const assets_folder_path = 'assets/'

// get_platform_dependent_asset_path Returns path to the asset.
// asset_path - a relative path to an asset from the `assets` folder. For example, if you have an asset with path
// `assets/config/test.txt`, provide `config/test.txt`.
//
// Since path to resources is different on different platform, use this method to get 'correct' one for the current platform.
//
// For Android, it will return the input value, since Android uses `os.read_apk_asset()` to read resource file,
// which is already "assets folder oriented".
//
// For all other platforms (for example Linux), it will return the absolute path to an asset.
pub fn get_platform_dependent_asset_path(asset_path string) string {
	$if android {
		return asset_path
	} $else {
		assets_folder_relative_path := os.join_path_single(common.assets_folder_path,
			asset_path)

		return os.resource_abs_path(assets_folder_relative_path)
	}
}
