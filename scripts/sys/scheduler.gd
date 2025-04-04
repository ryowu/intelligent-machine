extends Node

@export var enemy_schedule_path: String = ""

var enemy_normal_scene: PackedScene = preload("res://scene/planes/enemy_normal_1.tscn")
var enemy_shoot_1_scene: PackedScene = preload("res://scene/planes/enemy_shoot_1.tscn")
var enemy_support_scene: PackedScene = preload("res://scene/planes/enemy_support.tscn")

var boss_defender_normal_scene: PackedScene = preload("res://scene/boss/defender_normal.tscn")

var start_time = 0.0
var spawn_index = 0
var spawn_schedule = []
var is_paused = false
var is_running = false
var paused_time = 0.0

var audio_player = AudioStreamPlayer.new()

signal on_dialog_start(dialog_name: String)

func _ready():
	load_schedule_from_csv()
	add_child(audio_player)

func _process(_delta):
	if is_paused or !is_running:
		return

	var elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time - paused_time
	
	while spawn_index < spawn_schedule.size() and spawn_schedule[spawn_index]["time"] <= elapsed_time:
		spawn_enemy(spawn_schedule[spawn_index])
		spawn_index += 1

func spawn_enemy(event):
	var enemy_scene
	var skip_enemy_init = false
	match event["type"]:
		"normal":
			enemy_scene = enemy_normal_scene
		"support":
			enemy_scene = enemy_support_scene
		"shoot_1":
			enemy_scene = enemy_shoot_1_scene
		"defender_normal":
			enemy_scene = boss_defender_normal_scene
		"change_bgm":
			skip_enemy_init = true
			change_bgm(event["func_args"])
		"start_dialog":
			skip_enemy_init = true
			start_dialog(event["func_args"])
		_:
			print("Unknown enemy type: ", event["type"])
			return

	if !skip_enemy_init:
		var enemy_instance = enemy_scene.instantiate()
		get_parent().add_child(enemy_instance)
		enemy_instance.position = event["position"]

func append_enemy(time_line: float, _type: String, position: Vector2):
	spawn_schedule.append({
		"time": time_line,
		"type": _type,
		"position": position
	})

func append_command(time_line: float, func_name: String, func_args: String):
	spawn_schedule.append({
		"time": time_line,
		"type": func_name,
		"func_args": func_args
	})

func load_schedule_from_csv():
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
		if type == "command":
			var func_data = columns[2].strip_edges().split(" ")
			var func_name = func_data[0]
			var func_arg = func_data[1]
			append_command(time, func_name, func_arg)
		else:
			var position_data = columns[2].strip_edges().split(" ")
			var position = Vector2(float(position_data[0]), float(position_data[1]))
			append_enemy(time, type, position)

func change_bgm(bgm_path: String):
	if audio_player:
		audio_player.stop()
	
	var bgm = load(bgm_path) as AudioStream
	if bgm:
		audio_player.stream = bgm
		audio_player.volume_db = -10
		audio_player.play()

func start_dialog(dialog_name: String):
	pause()
	audio_player.volume_db = -20
	on_dialog_start.emit(dialog_name)

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
		audio_player.volume_db = -10
		start_time = Time.get_ticks_msec() / 1000.0 - paused_time
		print("Enemy spawning resumed")

func stop():
	is_running = false
	is_paused = false
	paused_time = 0.0
	start_time = 0.0
	spawn_index = 0
	print("Enemy spawning stopped and reset")
