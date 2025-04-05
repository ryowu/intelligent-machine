extends Area2D

const BASE_SCALE = 30

var start_position: Vector2
var time_passed := 0.0
var speed := 100.0
var screen_rect: Rect2
var direction_up = true
var scale_delta = 0

func _ready():
	set_as_top_level(true)
	start_position = position
	screen_rect = get_viewport().get_visible_rect()

func _process(delta):
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
	if position.x > screen_rect.end.x or position.y < screen_rect.position.y or position.y > screen_rect.end.y:
		queue_free()
