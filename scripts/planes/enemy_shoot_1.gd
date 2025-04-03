extends "res://scripts/planes/base_enemy.gd"

var fireball_scene: PackedScene = preload("res://scene/planes/enemy_fireball_sm.tscn") # Path to the fireball scene
@export var fireball_speed = 380 # Speed of the fireball
@export var fireball_shoot_interval = 2.5 # Interval to shoot fireballs in seconds

var fireball_timer: Timer

func _ready():
	# Call the parent class's ready function
	# Initialize and start a timer to shoot fireballs every 2 seconds
	fireball_timer = Timer.new()
	add_child(fireball_timer) # Add the timer to this enemy
	fireball_timer.wait_time = fireball_shoot_interval
	fireball_timer.one_shot = false  # Repeat forever
	fireball_timer.timeout.connect(_on_fireball_timer_timeout)
	fireball_timer.start()

func _on_fireball_timer_timeout():
	# Create and shoot a fireball to the left every 2 seconds
	shoot_fireball()

func shoot_fireball():
	print("shoot fireball")
	# Instantiate a new fireball
	var fireball = fireball_scene.instantiate()
	fireball.position = position # Set the fireball's position to the enemy's current position

	# Add the fireball to the scene
	get_parent().add_child(fireball)

	# Apply a velocity to the fireball to move it to the left
	#var direction = Vector2(-1, 0) # Direction to the left

func _physics_process(delta):
	# Ensure the enemy continues to move to the left like the base class
	super._physics_process(delta) # Call the parent class's physics process to keep moving left
	
func _disable_enemy():
	fireball_timer.stop()
	super._disable_enemy()
	
