extends "res://scripts/planes/base_enemy.gd"

@export var stop_position_x = 1000  # X position where the enemy stops
@export var stop_duration = 3.0  # Time to stop in seconds
@export var power_item_scene = preload("res://scene/items/power.tscn")
@export var fireball_scene = preload("res://scene/planes/enemy_fireball_sm.tscn")  # Fireball scene

var stopped = false
var has_stopped = false
var fireball_timer: Timer  # Timer node for continuous fireballs
var fireball_directions = [45, 0, -45, 0, 45, 0]  # Firing pattern
var fireball_index = 0  # Tracks the current fireball direction

func _ready():
	# Create and configure the timer
	fireball_timer = Timer.new()
	fireball_timer.wait_time = 1  # Fire every 1 second
	fireball_timer.autostart = false  # Do not start immediately
	fireball_timer.one_shot = false  # Repeat forever
	fireball_timer.timeout.connect(_spawn_fireball)
	add_child(fireball_timer)  # Attach timer to the enemy

func _physics_process(delta):
	if dying: return
	if stopped:
		return  # Stop moving for the delay

	if position.x <= stop_position_x and not stopped and not has_stopped:
		start_firing()
		stopped = true
		has_stopped = true
		await get_tree().create_timer(stop_duration).timeout  # Wait for stop duration
		stopped = false  # Resume moving
		speed = 120

	do_move(delta)

	if position.x < -300 or position.x < -get_viewport().size.x:
		queue_free()

# Starts firing fireballs every second
func start_firing():
	_spawn_fireball()
	fireball_timer.start()  # Start the timer

func _spawn_fireball():
	if dying: return  # Stop firing when dying

	var fireball = fireball_scene.instantiate()
	fireball.position = position + Vector2(-100, 0)
	get_parent().add_child(fireball)

	# Get the direction from the current angle
	var angle = fireball_directions[fireball_index]
	fireball.direction = Vector2.LEFT.rotated(deg_to_rad(angle))  # Fire to the left
	fireball_index = (fireball_index + 1) % fireball_directions.size()  # Cycle through angles

# Override play_explosion to add transparency effect before explosion
func play_explosion():
	dying = true
	fireball_timer.stop()  # Stop firing when dying

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
