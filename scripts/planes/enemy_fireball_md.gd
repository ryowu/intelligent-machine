extends Area2D

@export var speed = 400
var direction = Vector2.LEFT

func set_velocity(dir: Vector2):
	direction = dir.normalized()

func _physics_process(delta):
	position += direction * speed * delta

	var viewport_size = get_viewport_rect().size
	if position.x < -100 or position.x > viewport_size.x + 100 \
		or position.y < -100 or position.y > viewport_size.y + 100:
		queue_free()

func _on_area_entered(area: Area2D):
	if area.is_in_group("player") or area.is_in_group("player_child"):
		if area.has_method("die") and area.can_hurt():
			area.die()
		queue_free()
