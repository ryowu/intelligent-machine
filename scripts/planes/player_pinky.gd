extends "res://scripts/planes/base_player.gd"

const BULLET_SCENE = preload("res://scene/planes/pinky_bullet.tscn")

var bullet_offset = Vector2(60, 13)
var bullet_patterns = {
	1: [Vector2(0, -6)],
	2: [Vector2(0, -6), Vector2(0, 6)],
	3: [Vector2(0, -6), Vector2(0, 0), Vector2(0, 6)],
	4: [Vector2(0, -8), Vector2(0, -4), Vector2(0, 4), Vector2(0, 8)]
}

func _ready():
	super._ready()
	speed = 260

func fire_bullets():
	if bullet_patterns.has(power_level):
		for offset in bullet_patterns[power_level]:
			var bullet = build_bullet()
			bullet.position = position + bullet_offset + offset
		
func build_bullet():
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	return bullet
