extends Node

var enemy_normal_scene: PackedScene = preload("res://scene/planes/enemy_normal_1.tscn")
var enemy_support_scene: PackedScene = preload("res://scene/planes/enemy_support.tscn")

var start_time = 0.0  # Tracks when the level starts
var spawn_index = 0  # Tracks the next event to process

# Define the spawn schedule (Time in seconds, Enemy Type, Position)
var spawn_schedule = [
	# First wave (1300, 200) at 3s, 3.5s, 4s, 4.5s, 5s
	{ "time": 3, "type": "normal", "position": Vector2(1300, 200) },
	{ "time": 3.5, "type": "normal", "position": Vector2(1300, 200) },
	{ "time": 4, "type": "normal", "position": Vector2(1300, 200) },
	{ "time": 4.5, "type": "normal", "position": Vector2(1300, 200) },
	{ "time": 5, "type": "normal", "position": Vector2(1300, 200) },

	# Second wave (1300, 400) at 6.5s, 7s, 7.5s, 8s, 8.5s
	{ "time": 6.5, "type": "normal", "position": Vector2(1300, 400) },
	{ "time": 7, "type": "normal", "position": Vector2(1300, 400) },
	{ "time": 7.5, "type": "normal", "position": Vector2(1300, 400) },
	{ "time": 8, "type": "normal", "position": Vector2(1300, 400) },
	{ "time": 8.5, "type": "normal", "position": Vector2(1300, 400) },

	# Third wave (1300, 600) at 10s, 10.5s, 11s, 11.5s, 12s
	{ "time": 10, "type": "normal", "position": Vector2(1300, 600) },
	{ "time": 10.5, "type": "normal", "position": Vector2(1300, 600) },
	{ "time": 11, "type": "normal", "position": Vector2(1300, 600) },
	{ "time": 11.5, "type": "normal", "position": Vector2(1300, 600) },
	{ "time": 12, "type": "normal", "position": Vector2(1300, 600) },

	# Support enemy spawn at (1300, 400) at 13.5s
	{ "time": 13.5, "type": "support", "position": Vector2(1300, 400) }
]


func _ready():
	start_time = Time.get_ticks_msec() / 1000.0  # Get the start time in seconds

func _process(_delta):
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
