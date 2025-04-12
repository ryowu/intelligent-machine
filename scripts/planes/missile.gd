extends "res://scripts/planes/base_player_bullet.gd"

const BASE_SCALE = 30
var start_position: Vector2
var time_passed := 0.0
var direction_up = true
var scale_delta = 0

func _ready():
	speed = 100
	damage = GlobalConfig.BASIC_PLAYER_MISSILE_DAMAGE
	start_position = position

func _do_move(delta):
	time_passed += delta
	speed += 50 * delta
	var t = time_passed * speed * 0.01
	var x = t * (BASE_SCALE + scale_delta)
	var y = (t - 1.0) * (t - 1.0) * -150 + 150
	var y_pos = x
	if direction_up:
		y_pos = -y_pos
	var rotated = Vector2(-y, y_pos)
	position = start_position + rotated
