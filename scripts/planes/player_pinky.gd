extends "res://scripts/planes/base_player.gd"

const BULLET_SCENE = preload("res://scene/moving_objects/pinky_bullet.tscn")
const MISSILE_SCENE = preload("res://scene/moving_objects/tracking_missile.tscn") 
const ENERGY_ORB_SCENE = preload("res://scene/moving_objects/energy_orb.tscn")

var bullet_offset = Vector2(65, 10)
var bullet_patterns = {
	1: [Vector2(0, -2)],
	2: [Vector2(0, -8), Vector2(0, 4)],
	3: [Vector2(0, -10), Vector2(0, -2), Vector2(0, 6)],
	4: [Vector2(0, -12), Vector2(0, -5.3), Vector2(0, 1.4), Vector2(0, 8)]
}

func _ready():
	super._ready()
	#side_weapon_level = 1
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

func launch_skill():
	var orb = ENERGY_ORB_SCENE.instantiate()
	orb.position = position + Vector2(20, 5)
	get_tree().current_scene.add_child(orb)

func build_bullet():
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	return bullet

func build_missile():
	var missile = MISSILE_SCENE.instantiate()
	get_parent().add_child(missile)
	return missile
