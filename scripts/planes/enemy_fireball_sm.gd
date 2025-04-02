extends Area2D

@export var speed = 300  # Speed of the fireball
var direction = Vector2.LEFT  # Default direction (left)

func _physics_process(delta):
	position += direction.normalized() * speed * delta  # Move in the set direction

	# Remove fireball if it's far offscreen
	if position.x < -100 or position.x > get_viewport_rect().size.x + 100:
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("player"):  # Check if it hits the player
		area.die()  # Call player's death function
		queue_free()  # Remove fireball
