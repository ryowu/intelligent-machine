extends Node

var enemy_normal_scene: PackedScene = preload("res://scene/planes/enemy_normal_1.tscn")
var enemy_shoot_1_scene: PackedScene = preload("res://scene/planes/enemy_shoot_1.tscn")
var enemy_support_scene: PackedScene = preload("res://scene/planes/enemy_support.tscn")

var start_time = 0.0 # Tracks when the level starts
var spawn_index = 0 # Tracks the next event to process

var spawn_schedule = []

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0
	generate_3_normal_enemy(3, Vector2(1300, 200))
	generate_3_normal_enemy(6, Vector2(1300, 400))
	generate_3_normal_enemy(9, Vector2(1300, 300))
	append_enemy(13, "support", Vector2(1300, 400))
	append_enemy(15.5, "shoot_1", Vector2(1300, 150))
	append_enemy(16, "shoot_1", Vector2(1300, 250))
	append_enemy(16.5, "shoot_1", Vector2(1300, 350))
	append_enemy(17, "shoot_1", Vector2(1300, 450))
	append_enemy(17.5, "shoot_1", Vector2(1300, 550))
	append_enemy(18.5, "shoot_1", Vector2(1300, 150))
	append_enemy(19, "shoot_1", Vector2(1300, 200))
	append_enemy(19.5, "shoot_1", Vector2(1300, 250))
	append_enemy(20, "shoot_1", Vector2(1300, 300))
	append_enemy(20.5, "shoot_1", Vector2(1300, 350))

func _process(_delta):
	var elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time # Time elapsed since start
	
	# Process all spawn events in order
	while spawn_index < spawn_schedule.size() and spawn_schedule[spawn_index]["time"] <= elapsed_time:
		spawn_enemy(spawn_schedule[spawn_index]) # Spawn the enemy
		spawn_index += 1 # Move to the next event

func spawn_enemy(event):
	var enemy_scene
	match event["type"]:
		"normal":
			enemy_scene = enemy_normal_scene
		"support":
			enemy_scene = enemy_support_scene
		"shoot_1":
			enemy_scene = enemy_shoot_1_scene
		_:
			print("Unknown enemy type: ", event["type"])
			return # Don't spawn an unknown enemy

	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.position = event["position"]

func generate_3_normal_enemy(_start_time: float, start_position: Vector2):
	append_enemy(_start_time, "normal", start_position)
	append_enemy(_start_time + 0.5, "normal", Vector2(start_position.x, start_position.y - 50))
	append_enemy(_start_time + 0.5, "normal", Vector2(start_position.x, start_position.y + 50))
	append_enemy(_start_time + 1, "normal", Vector2(start_position.x, start_position.y - 100))
	append_enemy(_start_time + 1, "normal", Vector2(start_position.x, start_position.y))
	append_enemy(_start_time + 1, "normal", Vector2(start_position.x, start_position.y + 100))

func append_enemy(time_line: float, _type: String, position: Vector2):
	spawn_schedule.append({
			"time": time_line,
			"type": _type,
			"position": Vector2(position)
		})
