extends "res://scripts/planes/base_shootable_enemy.gd"

var speed_item_scene = preload("res://scene/items/speed_item.tscn")

func _ready():
	super._ready()
	path_points = [
		Vector2(900, -1),
		Vector2(900, 100),
		Vector2(900, 500),
		Vector2(900, 350)
	]
	path_points[0].y = position.y
	fireball_timer.start()

func shoot_fireball():
	var angles = [-10, 0, 10]
	for angle in angles:
		var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
		var fireball = fireball_scene.instantiate()
		fireball.position = position + Vector2(-80, 10)
		fireball.set_velocity(dir * 200)
		get_parent().add_child(fireball)

func spawn_items():
	drop_widget(speed_item_scene)
