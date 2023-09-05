module obstacle

import collision
import graphics
import common
import ecs
import artemkakun.trnsfrm2d

pub fn spawn_bottom_obstacle(mut ecs_world ecs.World, screen_height int, polygon_height f64, polygon_convex_parts [][]trnsfrm2d.Position, app graphics.App, polygon_width f64, position_shift int) &ecs.Entity {
	return ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: polygon_width * position_shift
			y: screen_height - polygon_height
		},
		ecs.RenderData{
			image_id: graphics.get_bottom_obstacle_image(app).id
			orientation: common.Orientation.right
		},
		collision.Collider{
			normalized_convex_polygons: polygon_convex_parts
			collidable_types: collision.CollisionType.chicken
			collider_type: collision.CollisionType.obstacle
			width: polygon_width
			height: polygon_height
		},
	])
}
