extends "res://scripts/planes/base_player_bullet.gd"

var turn_speed = 4.0
var target: Area2D

func _ready():
	speed = 450
	damage = GlobalConfig.BASIC_PLAYER_MISSILE_DAMAGE
	if target == null:
		target = _find_closest_enemy()

func _do_move(delta):
	if target and is_instance_valid(target):
		var to_target = (target.global_position - global_position).normalized()
		direction = Vector2.RIGHT.rotated(rotation)
		var angle_diff = direction.angle_to(to_target)
		angle_diff = clamp(angle_diff, -turn_speed * delta, turn_speed * delta)
		rotation += angle_diff

	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _find_closest_enemy() -> Area2D:
	var enemies = get_tree().get_nodes_in_group("enemy")
	var closest = null
	var min_dist = INF

	for enemy in enemies:
		#if not enemy is Area2D: continue
		var dist = global_position.distance_to(enemy.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = enemy
	return closest
