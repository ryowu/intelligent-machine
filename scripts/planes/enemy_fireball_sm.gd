extends Area2D

@export var speed = 300
var direction = Vector2.LEFT
@export var rotation_speed = 8.0

func set_velocity(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	position += direction * speed * delta
	rotation += rotation_speed * delta

	var viewport_size = get_viewport_rect().size
	if position.x < -100 or position.x > viewport_size.x + 100 \
		or position.y < -100 or position.y > viewport_size.y + 100:
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("player"):
		if area.has_method("die"):
			area.die()
		queue_free()
