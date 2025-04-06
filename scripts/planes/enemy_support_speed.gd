extends "res://scripts/planes/base_shootable_enemy.gd"

var speed_item_scene = preload("res://scene/items/speed_item.tscn")

var path_points = [
	Vector2(900, -1),
	Vector2(900, 100),
	Vector2(900, 500),
	Vector2(900, 350)
]

var move_speed = 150
@export var final_move_speed = 60

func _ready():
	super._ready()
	path_points[0].y = position.y
	fireball_timer.start()

func do_move(delta):
	if current_path_index < path_points.size():
		var target = path_points[current_path_index]
		var direction = (target - position).normalized()
		position += direction * move_speed * delta
		if position.distance_to(target) < 5:
			current_path_index += 1
	else:
		position.x -= final_move_speed * delta

func _on_fireball_timer_timeout():
	var angles = [-10, 0, 10]
	for angle in angles:
		var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
		var fireball = fireball_scene.instantiate()
		fireball.position = position + Vector2(-80, 10)
		fireball.set_velocity(dir * 200)
		get_parent().add_child(fireball)

func spawn_items():
	var speed_item = speed_item_scene.instantiate()
	speed_item.position = position
	get_parent().add_child(speed_item)
