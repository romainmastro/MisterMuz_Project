extends Node2D

var debug_points: Array[Vector2] = []
var color := Color.RED
var radius := 4.0

func set_debug_point(world_position: Vector2, col := Color.RED, r := 1.0):
	debug_points.clear()
	debug_points.append(world_position)
	color = col
	radius = r
	queue_redraw()

func _draw():
	for world_pos in debug_points:
		var local_point = get_global_transform().affine_inverse() * world_pos
		draw_circle(local_point, radius, color)
