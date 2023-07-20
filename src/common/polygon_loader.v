module common

import artemkakun.trnsfrm2d
import artemkakun.pcoll2d
import json
import os

pub fn load_polygon_and_get_convex_parts(polygon_file_name string) ![][]trnsfrm2d.Position {
	polygon_file_path := get_platform_dependent_asset_path('${polygon_file_name}${pcoll2d.polygon_file_extension}')
	polygon_data := os.read_file(polygon_file_path)!
	polygon := json.decode(pcoll2d.Polygon, polygon_data)!

	return pcoll2d.decompose(polygon.points)
}
