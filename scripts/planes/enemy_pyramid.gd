extends "res://scripts/planes/base_shootable_enemy.gd"

var player: Area2D

func _ready():
	fireball_shoot_interval = 2
	super._ready()

	hp = 10
	speed = 250
	score = 200
	coin_count = 1

	path_points = [
		Vector2(800, position.y),
		Vector2(150, 450),
		Vector2(800, 450),
		Vector2(-200, -200),
	]
	fireball_timer.start()

func shoot_fireball():
	player = get_parent().get_node(GlobalConfig.PLAYER_NODE_NAME)
	if is_instance_valid(player):
		var fireball = fireball_scene.instantiate()
		fireball.position = position
		fireball.speed = 300
		get_parent().add_child(fireball)
		
		var dir = (player.global_position - fireball.position).normalized()
		fireball.set_velocity(dir * 200)
