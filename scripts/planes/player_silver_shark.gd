extends "res://scripts/planes/base_player.gd"

const BULLET_SCENE = preload("res://scene/planes/player_bullet_green.tscn")
const MISSILE_SCENE = preload("res://scene/planes/player_missile.tscn") 
const GREY_FOX_SCENE = preload("res://scene/planes/child_grey_fox.tscn")

func fire_side_weapon():
	if side_weapon_level == 1:
		var missile1 = build_missile()
		missile1.direction_up = false
		missile1.start_position = position + Vector2(0, 15)
		var missile2 = build_missile()
		missile2.start_position = position + Vector2(0, 15)
	elif side_weapon_level == 2:
		var missile1 = build_missile()
		missile1.direction_up = false
		missile1.scale_delta = 20
		missile1.start_position = position + Vector2(0, 15)
		var missile2 = build_missile()
		missile2.direction_up = false
		missile2.start_position = position + Vector2(0, 15)
		var missile3 = build_missile()
		missile3.scale_delta = 20
		missile3.start_position = position + Vector2(0, 15)
		var missile4 = build_missile()
		missile4.start_position = position + Vector2(0, 15)

func fire_bullets():
	var angles = []
	var bullet_offset = Vector2(60, 15)
	var bullet_mode = 3

	if power_level == 1:
		if even_bullet_counter:
			bullet_mode = 3
		else:
			bullet_mode = 1
		even_bullet_counter = !even_bullet_counter
		angles = [0]
	elif power_level == 2:
		bullet_mode = 3
		var bullet1 = build_bullet(bullet_mode)
		bullet1.position = position + bullet_offset + Vector2(0, -6)
		var bullet2 = build_bullet(bullet_mode)
		bullet2.position = position + bullet_offset + Vector2(0, 6)
	elif power_level == 3:
		bullet_mode = 3
		angles = [-10, 0, 10]
	elif power_level == 4:
		var bullet1 = build_bullet(bullet_mode)
		bullet1.position = position + bullet_offset + Vector2(0, -6)
		var bullet2 = build_bullet(bullet_mode)
		bullet2.position = position + bullet_offset + Vector2(0, 6)
		angles = [-10, 10]

	for angle in angles:
		var bullet = build_bullet(bullet_mode)
		bullet.position = position + bullet_offset
		var direction = Vector2(1, 0).rotated(deg_to_rad(angle))
		bullet.direction = direction.normalized()
	# shot_audio.play()

func launch_skill():
	var fox1 = GREY_FOX_SCENE.instantiate()
	fox1.position = Vector2(-200, position.y - 60)
	get_tree().current_scene.add_child(fox1)

	var fox2 = GREY_FOX_SCENE.instantiate()
	fox2.position = Vector2(-200, position.y)
	get_tree().current_scene.add_child(fox2)

	var fox3 = GREY_FOX_SCENE.instantiate()
	fox3.position = Vector2(-200, position.y + 60)
	get_tree().current_scene.add_child(fox3)

func build_bullet(bullet_mode: int):
	var bullet = BULLET_SCENE.instantiate()
	bullet.bullet_mode = bullet_mode
	get_parent().add_child(bullet)
	return bullet

func build_missile():
	var missile = MISSILE_SCENE.instantiate()
	get_parent().add_child(missile)
	return missile
