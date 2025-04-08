extends "res://scripts/planes/base_shootable_enemy.gd"

var mode: int

func _ready():
	super._ready()
	if mode == 0:
		path_points = [
			Vector2(900, 285),
			Vector2(900, -300)
		]
	else:
		path_points = [
			Vector2(900, 350),
			Vector2(900, 700)
		]
	fireball_timer.start()

func shoot_fireball():
	var angles = [-15, 0, 15]
	for angle in angles:
		var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
		var fireball = fireball_scene.instantiate()
		fireball.position = position + Vector2(-80, 10)
		fireball.set_velocity(dir * 200)
		get_parent().add_child(fireball)
