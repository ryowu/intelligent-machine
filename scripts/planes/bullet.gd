extends Area2D

@export var speed = 1500
@export var direction = Vector2(1, 0)
@export var bullet_mode := 3

const BULLET_IMAGES = {
	1: preload("res://assets/img/planes/player/player_bullet_lg.png"),
	2: preload("res://assets/img/planes/player/player_bullet_single.png"),
	3: preload("res://assets/img/planes/player/player_bullet_sm.png")
}

@onready var sprite: Sprite2D = $Bullet

func _ready():
	set_as_top_level(true)
	sprite.texture = BULLET_IMAGES.get(bullet_mode, BULLET_IMAGES[1])

func _physics_process(delta):
	position += direction.normalized() * speed * delta

	var viewport_size = get_viewport().get_visible_rect().size
	if position.x > viewport_size.x or position.y > viewport_size.y or position.x < 0 or position.y < 0:
		queue_free()
