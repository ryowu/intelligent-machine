extends "res://scripts/planes/base_enemy.gd"

@onready var fireball_scene: PackedScene = preload("res://scene/planes/enemy_fireball_sm.tscn")
@onready var fire_timer: Timer = $FireTimer
var speed_item_scene = preload("res://scene/items/speed_item.tscn")
# Movement sequence
var path_points = [
	Vector2(900, -1),  # X only, Y will be taken from start position
	Vector2(900, 100),
	Vector2(900, 500),
	Vector2(900, 350)
]
var current_path_index = 0
var move_speed = 150
var final_move_speed = 60

func _ready():
	path_points[0].y = position.y  # Keep original Y for first move
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	fire_timer.start(1.5)

func do_move(delta):
	if dying:
		return
	
	if current_path_index < path_points.size():
		var target = path_points[current_path_index]
		var direction = (target - position).normalized()
		position += direction * move_speed * delta
		if position.distance_to(target) < 5:
			current_path_index += 1
	else:
		position.x -= final_move_speed * delta

func _on_fire_timer_timeout():
	if dying:
		return
	var angles = [-10, 0, 10]
	for angle in angles:
		var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
		var fireball = fireball_scene.instantiate()
		fireball.position = position + Vector2(-80, 10)
		fireball.set_velocity(dir * 200)
		get_parent().add_child(fireball)

func spawn_coins():
	var speed_item = speed_item_scene.instantiate()
	speed_item.position = position
	get_parent().add_child(speed_item)
