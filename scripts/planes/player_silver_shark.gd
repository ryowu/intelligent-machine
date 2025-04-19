extends "res://scripts/planes/base_player.gd"

const BULLET_SCENE = preload("res://scene/moving_objects/player_bullet_green.tscn")
const MISSILE_SCENE = preload("res://scene/moving_objects/player_missile.tscn") 
const GREY_FOX_SCENE = preload("res://scene/moving_objects/child_grey_fox.tscn")

func fire_side_weapon():
	var base_position = position + Vector2(0, 15)
	var missiles = []

	match side_weapon_level:
		1:
			missiles = [
				{ "direction_up": false },
				{ }  # default upward
			]
		2:
			missiles = [
				{ "direction_up": false, "scale_delta": 20 },
				{ "direction_up": false },
				{ "scale_delta": 20 },
				{ }  # default upward
			]

	for missile_data in missiles:
		var missile = build_missile()
		missile.start_position = base_position
		if missile_data.has("direction_up"):
			missile.direction_up = missile_data["direction_up"]
		if missile_data.has("scale_delta"):
			missile.scale_delta = missile_data["scale_delta"]


func fire_bullets():
	var bullet_offset = Vector2(60, 15)
	var bullet_mode = 3
	var spawn_offsets = []
	var angles = []

	match power_level:
		1:
			bullet_mode = 3 if even_bullet_counter else 1
			even_bullet_counter = !even_bullet_counter
			angles = [0]
		2:
			bullet_mode = 3
			spawn_offsets = [Vector2(0, -6), Vector2(0, 6)]
		3:
			bullet_mode = 3
			angles = [-10, 0, 10]
		4:
			spawn_offsets = [Vector2(0, -6), Vector2(0, 6)]
			angles = [-10, 10]
	# Spawn bullets based on offsets (if defined)
	for offset in spawn_offsets:
		var bullet = build_bullet(bullet_mode)
		bullet.position = position + bullet_offset + offset
	# Spawn bullets based on angles (if defined)
	for angle in angles:
		var bullet = build_bullet(bullet_mode)
		bullet.position = position + bullet_offset
		bullet.direction = Vector2(1, 0).rotated(deg_to_rad(angle)).normalized()
	# shot_audio.play()

func launch_skill():
	var y_offsets = [-60, 0, 60]
	for offset in y_offsets:
		var fox = GREY_FOX_SCENE.instantiate()
		fox.position = Vector2(-200, position.y + offset)
		get_tree().current_scene.add_child(fox)

func build_bullet(bullet_mode: int):
	var bullet = BULLET_SCENE.instantiate()
	bullet.bullet_mode = bullet_mode
	get_parent().add_child(bullet)
	return bullet

func build_missile():
	var missile = MISSILE_SCENE.instantiate()
	get_parent().add_child(missile)
	return missile
