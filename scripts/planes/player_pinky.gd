extends "res://scripts/planes/base_player.gd"

const BULLET_SCENE = preload("res://scene/planes/pinky_bullet.tscn")
const MISSILE_SCENE = preload("res://scene/planes/tracking_missile.tscn") 

var bullet_offset = Vector2(60, 13)
var bullet_patterns = {
	1: [Vector2(0, -6)],
	2: [Vector2(0, -6), Vector2(0, 6)],
	3: [Vector2(0, -6), Vector2(0, 0), Vector2(0, 6)],
	4: [Vector2(0, -8), Vector2(0, -4), Vector2(0, 4), Vector2(0, 8)]
}

func _ready():
	super._ready()
	side_weapon_level = 1
	speed = 260

func fire_bullets():
	if bullet_patterns.has(power_level):
		for offset in bullet_patterns[power_level]:
			var bullet = build_bullet()
			bullet.position = position + bullet_offset + offset

func fire_side_weapon():
	var missile_offsets = []
	var initial_angles = []

	if side_weapon_level == 1:
		missile_offsets = [Vector2(0, -10), Vector2(0, 10)]
		initial_angles = [-15, 15]
	elif side_weapon_level == 2:
		missile_offsets = [Vector2(0, -15), Vector2(0, -5), Vector2(0, 5), Vector2(0, 15)]
		initial_angles = [-20, -10, 10, 20]

	for i in range(missile_offsets.size()):
		var missile = build_missile()
		missile.position = position + missile_offsets[i]
		missile.rotation = deg_to_rad(initial_angles[i])

		#missile.target = null 

func build_bullet():
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	return bullet

func build_missile():
	var missile = MISSILE_SCENE.instantiate()
	get_parent().add_child(missile)
	return missile
