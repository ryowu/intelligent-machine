extends "res://scripts/planes/base_enemy.gd"

var current_path_index = 0
var path_points = []

func do_move(delta):
	if current_path_index < path_points.size():
		var target = path_points[current_path_index]
		var direction = (target - position).normalized()
		position += direction * speed * delta
		if position.distance_to(target) < 5:
			current_path_index += 1
	else:
		super.do_move(delta)