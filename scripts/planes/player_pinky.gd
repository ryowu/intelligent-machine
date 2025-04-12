extends "res://scripts/planes/base_player.gd"

const BULLET_SCENE = preload("res://scene/planes/pinky_bullet.tscn")

func _ready():
	super._ready()
	speed = 260

func fire_bullets():
	var bullet_offset = Vector2(60, 13)

	if power_level == 1:
		var bullet1 = build_bullet()
		bullet1.position = position + bullet_offset + Vector2(0, -6)
	elif power_level == 2:
		var bullet1 = build_bullet()
		bullet1.position = position + bullet_offset + Vector2(0, -6)
		var bullet2 = build_bullet()
		bullet2.position = position + bullet_offset + Vector2(0, 6)
	elif power_level == 3:
		var bullet1 = build_bullet()
		bullet1.position = position + bullet_offset + Vector2(0, -6)
		var bullet2 = build_bullet()
		bullet2.position = position + bullet_offset
		var bullet3 = build_bullet()
		bullet3.position = position + bullet_offset + Vector2(0, 6)
	elif power_level == 4:
		var bullet1 = build_bullet()
		bullet1.position = position + bullet_offset + Vector2(0, -8)
		var bullet2 = build_bullet()
		bullet2.position = position + bullet_offset + Vector2(0, -4)
		var bullet3 = build_bullet()
		bullet3.position = position + bullet_offset + Vector2(0, 4)
		var bullet4 = build_bullet()
		bullet4.position = position + bullet_offset + Vector2(0, 8)
		
func build_bullet():
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	return bullet
