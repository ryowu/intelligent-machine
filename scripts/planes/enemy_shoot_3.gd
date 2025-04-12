extends "res://scripts/planes/base_shootable_enemy.gd"

@onready var player: Area2D = get_parent().get_node("Player1")

func _ready():
	super._ready()

	hp = 10
	speed = 250
	score = 200
	coin_count = 1

	path_points = [
		Vector2(800, position.y),
		Vector2(1500, position.y),
	]
	fireball_timer.start()

func shoot_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.position = position
	fireball.speed = 200
	get_parent().add_child(fireball)
	var dir = (player.global_position - fireball.position).normalized()
	fireball.set_velocity(dir * 200)

func on_path_point_reached(_index: int):
	speed = 30
