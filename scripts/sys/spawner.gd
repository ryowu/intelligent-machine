extends Node

var enemy_normal_scene: PackedScene = preload("res://scene/planes/enemy_normal_1.tscn")
var enemy_support_scene: PackedScene = preload("res://scene/planes/enemy_support.tscn")

var start_time = 0.0  # Tracks when the level starts
var spawn_index = 0  # Tracks the next event to process

# Define the spawn schedule (Time in seconds, Enemy Type, Position)
var spawn_schedule = [
	{ "time": 3, "type": "normal", "position": Vector2(1300, 200) },
	{ "time": 3, "type": "normal", "position": Vector2(1300, 400) },
	{ "time": 10, "type": "support", "position": Vector2(1300, 300) },
	{ "time": 15, "type": "normal", "position": Vector2(1300, 100) },
	{ "time": 15, "type": "normal", "position": Vector2(1300, 500) },
]

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0  # Get the start time in seconds

func _process(delta):
	var elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time  # Time elapsed since start
	
	# Process all spawn events in order
	while spawn_index < spawn_schedule.size() and spawn_schedule[spawn_index]["time"] <= elapsed_time:
		spawn_enemy(spawn_schedule[spawn_index])  # Spawn the enemy
		spawn_index += 1  # Move to the next event

func spawn_enemy(event):
	var enemy_scene
	match event["type"]:
		"normal":
			enemy_scene = enemy_normal_scene
		"support":
			enemy_scene = enemy_support_scene
		_:
			print("Unknown enemy type: ", event["type"])
			return  # Don't spawn an unknown enemy

	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.position = event["position"]
