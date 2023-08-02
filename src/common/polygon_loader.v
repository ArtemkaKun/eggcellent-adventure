module common

import artemkakun.trnsfrm2d
import artemkakun.pcoll2d
import json
import os

// load_polygon_and_get_convex_parts loads polygon from a polygon file that has the same name as the image file
// scales the polygon by image_scale
// and returns a list of convex polygons
pub fn load_polygon_and_get_convex_parts(image_file_path string, image_scale int) ![][]trnsfrm2d.Position {
	assets_folder_relative_path := image_file_path.all_after('assets/')

	polygon_file_path := get_platform_dependent_asset_path(assets_folder_relative_path.replace('.png',
		pcoll2d.polygon_file_extension))

	mut polygon := pcoll2d.Polygon{}

	$if android {
		polygon_data := os.read_apk_asset(polygon_file_path)!
		polygon = json.decode(pcoll2d.Polygon, polygon_data.bytestr())!
	} $else {
		polygon_data := os.read_file(polygon_file_path)!
		polygon = json.decode(pcoll2d.Polygon, polygon_data)!
	}

	convex_polygons := pcoll2d.decompose(polygon.points)

	mut scaled_convex_polygons := [][]trnsfrm2d.Position{}

	for convex_polygon in convex_polygons {
		mut scaled_convex_polygon := []trnsfrm2d.Position{}

		for vertex in convex_polygon {
			scaled_convex_polygon << trnsfrm2d.Position{
				x: vertex.x * image_scale
				y: vertex.y * image_scale
			}
		}

		scaled_convex_polygons << scaled_convex_polygon
	}

	return scaled_convex_polygons
}
