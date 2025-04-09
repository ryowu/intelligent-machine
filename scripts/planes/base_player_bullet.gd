extends Area2D

@export var speed = 1500
@export var direction = Vector2(1, 0)

@onready var sprite: Sprite2D = $Bullet

func _ready():
	set_as_top_level(true)

func _physics_process(delta):
	position += direction.normalized() * speed * delta

	var viewport_size = get_viewport().get_visible_rect().size
	if position.x > viewport_size.x or position.y > viewport_size.y or position.x < 0 or position.y < 0:
		queue_free()
