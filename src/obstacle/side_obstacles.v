module obstacle

import collision
import graphics
import common
import artemkakun.trnsfrm2d
import ecs

pub fn spawn_side_obstacles(app graphics.App, images_scale int, mut ecs_world ecs.World, screen_width int, obstacle_move_vector trnsfrm2d.Vector) {
	side_obstacle_polygon_convex_parts := common.load_polygon_and_get_convex_parts(graphics.get_side_obstacle_right_image(app).path,
		images_scale) or { panic("Can't load side obstacle's polygon - ${err}") }

	polygon_width := collision.calculate_polygon_collider_width(side_obstacle_polygon_convex_parts)
	polygon_height := collision.calculate_polygon_collider_height(side_obstacle_polygon_convex_parts)

	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: screen_width - polygon_width / 2 + 5
			y: -polygon_height
		},
		ecs.Velocity{
			x: obstacle_move_vector.x
			y: obstacle_move_vector.y
		},
		ecs.RenderData{
			image_id: graphics.get_side_obstacle_right_image(app).id
			orientation: common.Orientation.right
		},
		EndlessElement{
			already_continued: false
		},
		collision.Collider{
			normalized_convex_polygons: side_obstacle_polygon_convex_parts
			collidable_types: collision.CollisionType.chicken
			collider_type: collision.CollisionType.obstacle
			width: polygon_width
			height: collision.calculate_polygon_collider_height(side_obstacle_polygon_convex_parts)
		},
	])

	ecs.register_entity(mut ecs_world, [
		ecs.Position{
			x: 0 - polygon_width / 2 + 5
			y: -polygon_height
		},
		ecs.Velocity{
			x: obstacle_move_vector.x
			y: obstacle_move_vector.y
		},
		ecs.RenderData{
			image_id: graphics.get_side_obstacle_right_image(app).id
			orientation: common.Orientation.left
		},
		EndlessElement{
			already_continued: false
		},
		collision.Collider{
			normalized_convex_polygons: side_obstacle_polygon_convex_parts
			collidable_types: collision.CollisionType.chicken
			collider_type: collision.CollisionType.obstacle
			width: polygon_width
			height: collision.calculate_polygon_collider_height(side_obstacle_polygon_convex_parts)
		},
	])
}
