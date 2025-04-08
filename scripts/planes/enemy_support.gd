extends "res://scripts/planes/base_shootable_enemy.gd"

@export var stop_position_x = 1000
@export var stop_duration = 2.0
@export var power_item_scene = preload("res://scene/items/power.tscn")
@export var side_weapon_scene = preload("res://scene/items/side_power.tscn")

var stopped = false
var has_stopped = false
var fireball_directions = [45, 0, -45, 0, 45, 0]
var fireball_index = 0
var mode = 0

func _physics_process(delta):
	if stopped:
		return

	if position.x <= stop_position_x and not stopped and not has_stopped:
		start_firing()
		stopped = true
		has_stopped = true
		await get_tree().create_timer(stop_duration).timeout
		stopped = false
		speed = 120

	do_move(delta)

	if position.x < -300 or position.x < -get_viewport().size.x:
		queue_free()

func start_firing():
	shoot_fireball()
	fireball_timer.start()

func shoot_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.position = position + Vector2(-100, 0)
	get_parent().add_child(fireball)

	var angle = fireball_directions[fireball_index]
	fireball.direction = Vector2.LEFT.rotated(deg_to_rad(angle))
	fireball_index = (fireball_index + 1) % fireball_directions.size()

func play_explosion():
	dying = true
	fireball_timer.stop()

	# Fade to 80% transparency over 2 seconds
	# var tween = get_tree().create_tween()
	# tween.tween_property(enemy_body, "modulate", Color(1, 1, 1, 0.2), 0.3)
	# await tween.finished

	explosion.visible = true
	explode_audio.play()
	explosion.play("explode_big")

	# Disable collision and wait for explosion animation
	call_deferred("_disable_enemy")
	await explosion.animation_finished

	# Spawn the power item at the enemy's position after explosion
	spawn_power_item()

	# Queue the enemy for removal after the explosion animation finishes
	queue_free()

func spawn_power_item():
	if mode == 0:
		drop_widget(power_item_scene)
	elif mode == 1:
		drop_widget(side_weapon_scene)
