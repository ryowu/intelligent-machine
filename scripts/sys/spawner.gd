extends Node

@export var enemy_schedule_path: String = ""

var enemy_normal_scene: PackedScene = preload("res://scene/planes/enemy_normal_1.tscn")
var enemy_shoot_1_scene: PackedScene = preload("res://scene/planes/enemy_shoot_1.tscn")
var enemy_support_scene: PackedScene = preload("res://scene/planes/enemy_support.tscn")

var start_time = 0.0
var spawn_index = 0
var spawn_schedule = []
var is_paused = false
var is_running = false
var paused_time = 0.0

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0
	load_enemy_schedule_from_csv()

func _process(_delta):
	if is_paused or !is_running:
		return

	var elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time - paused_time
	
	while spawn_index < spawn_schedule.size() and spawn_schedule[spawn_index]["time"] <= elapsed_time:
		spawn_enemy(spawn_schedule[spawn_index])
		spawn_index += 1

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
			return

	var enemy_instance = enemy_scene.instantiate()
	get_parent().add_child(enemy_instance)
	enemy_instance.position = event["position"]

func append_enemy(time_line: float, _type: String, position: Vector2):
	spawn_schedule.append({
		"time": time_line,
		"type": _type,
		"position": position
	})

func load_enemy_schedule_from_csv():
	var file = FileAccess.open(enemy_schedule_path, FileAccess.READ)
	if file == null:
		print("Failed to open enemy schedule CSV file")
		return
	var content = file.get_as_text()
	file.close()
	var lines = content.split("\r\n", false)
	for line in lines:
		if line.is_empty() or line.begins_with("#"):
			continue
		var columns = line.split(",")
		if columns.size() != 3:
			continue
		var time = float(columns[0].strip_edges())
		var type = columns[1].strip_edges()
		var position_data = columns[2].strip_edges().split(" ")
		var position = Vector2(float(position_data[0]), float(position_data[1]))
		append_enemy(time, type, position)

func start():
	if !is_running:
		is_running = true
		start_time = Time.get_ticks_msec() / 1000.0 - paused_time
		paused_time = 0.0
		spawn_index = 0
		print("Enemy spawning started")

func pause():
	if is_running and !is_paused:
		is_paused = true
		paused_time = Time.get_ticks_msec() / 1000.0 - start_time
		print("Enemy spawning paused")

func resume():
	if is_paused:
		is_paused = false
		start_time = Time.get_ticks_msec() / 1000.0 - paused_time
		print("Enemy spawning resumed")

func stop():
	is_running = false
	is_paused = false
	paused_time = 0.0
	start_time = 0.0
	spawn_index = 0
	print("Enemy spawning stopped and reset")
