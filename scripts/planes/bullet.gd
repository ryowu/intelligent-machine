extends Area2D

@export var speed = 1500  # Speed factor (magnitude of movement)
@export var direction = Vector2(1, 0)  # Direction vector (default is moving right)

func _ready():
	set_as_top_level(true)  # Ensure the bullet moves independently

func _physics_process(delta):
	position += direction.normalized() * speed * delta  # Move based on direction

	# Remove bullet when it goes off-screen
	var viewport_size = get_viewport().get_visible_rect().size
	if position.x > viewport_size.x or position.y > viewport_size.y or position.x < 0 or position.y < 0:
		queue_free()
