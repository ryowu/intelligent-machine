extends "res://scripts/planes/base_enemy.gd"

@export var stop_position_x = 1000  # X position where the enemy stops
@export var stop_duration = 3.0  # Time to stop in seconds
@export var power_item_scene = preload("res://scene/items/power.tscn")

var stopped = false
var has_stopped = false

func _physics_process(delta):
	if dying: return
	if stopped:
		return  # Stop moving for the delay

	if position.x <= stop_position_x and not stopped and not has_stopped:
		stopped = true
		has_stopped = true
		await get_tree().create_timer(stop_duration).timeout  # Wait for stop duration
		stopped = false  # Resume moving
		speed = 120

	do_move(delta)

	if position.x < -300 or position.x < -get_viewport().size.x:
		queue_free()

# Override play_explosion to add transparency effect before explosion
func play_explosion():
	dying = true

	# Fade to 80% transparency over 2 seconds
	var tween = get_tree().create_tween()
	tween.tween_property(enemy_body, "modulate", Color(1, 1, 1, 0.2), 0.3)
	await tween.finished

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

# Function to spawn the power item
func spawn_power_item():
	# Instantiate the power item
	var power_item = power_item_scene.instantiate()
	power_item.position = position
	get_parent().add_child(power_item)
