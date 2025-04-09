extends Area2D
@onready var timer: Timer = $Timer

const BULLET_SCENE = preload("res://scene/planes/child_bullet_blue.tscn")
const BULLET_INTERVAL = 0.2

var velocity = Vector2.ZERO
var shooting = false
var stage = 0
var stage_time = 0.0

func _ready():
	position.x = -200
	velocity = Vector2.RIGHT * 200

func _process(delta):
	stage_time += delta
	position += velocity * delta

	match stage:
		0:
			if position.x >= 150:
				stage = 1
				stage_time = 0.0
				velocity = Vector2.RIGHT * 50
				shooting = true
				start_firing()
		1:
			if stage_time >= 5.0:
				stage = 2
				velocity = Vector2.RIGHT * 260
		2:
			pass

	if position.x > 1500:
		queue_free()

func start_firing():
	spawn_bullet()
	timer.start(BULLET_INTERVAL)

func spawn_bullet():
	var bullet = BULLET_SCENE.instantiate()
	bullet.position = position
	bullet.direction = Vector2.RIGHT
	get_tree().current_scene.add_child(bullet)

func _on_timer_timeout() -> void:
	if shooting:
		spawn_bullet()
