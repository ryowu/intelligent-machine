extends Node

@export var enemy_schedule_path: String = ""
@onready var boss_hp_bar: ProgressBar = $"../ui_panel/boss_hp"

var enemy_normal_scene: PackedScene = preload("res://scene/moving_objects/enemy_normal_1.tscn")
var enemy_shoot_1_scene: PackedScene = preload("res://scene/moving_objects/enemy_shoot_1.tscn")
var enemy_shoot_2_scene: PackedScene = preload("res://scene/moving_objects/enemy_shoot_2.tscn")
var enemy_shoot_3_scene: PackedScene = preload("res://scene/moving_objects/enemy_shoot_3.tscn")
var enemy_support_scene: PackedScene = preload("res://scene/moving_objects/enemy_support.tscn")
var enemy_support_speed_scene: PackedScene = preload("res://scene/moving_objects/enemy_support_speed.tscn")
var enemy_sphinx_tank_scene: PackedScene = preload("res://scene/moving_objects/sphinx_tank.tscn")

var boss_xuanwu_scene: PackedScene = preload("res://scene/boss/xuanwu.tscn")
var warning_scene: PackedScene = preload("res://scene/sys/warning.tscn")

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
		execute_schedule_item(spawn_schedule[spawn_index])
		spawn_index += 1

func execute_schedule_item(event):
	var enemy_scene
	var skip_enemy_init = false
	match event["type"]:
		"normal":
			enemy_scene = enemy_normal_scene
		"support":
			enemy_scene = enemy_support_scene
		"support_speed":
			enemy_scene = enemy_support_speed_scene
		"shoot_1":
			enemy_scene = enemy_shoot_1_scene
		"shoot_2":
			enemy_scene = enemy_shoot_2_scene
		"shoot_3":
			enemy_scene = enemy_shoot_3_scene
		"sphinx_tank":
			enemy_scene = enemy_sphinx_tank_scene			
		"xuanwu":
			enemy_scene = boss_xuanwu_scene
		"change_bgm":
			skip_enemy_init = true
			change_bgm(event["func_args"])
		"fade_out_bgm":
			skip_enemy_init = true
			fade_out_audio(float(event["func_args"]))
		"warning":
			skip_enemy_init = true
			show_warning(float(event["func_args"]))
		"stop":
			skip_enemy_init = true
			is_running = false
		"start_dialog":
			skip_enemy_init = true
			start_dialog(event["func_args"])
		_:
			print("Unknown enemy type: ", event["type"])
			return

	if !skip_enemy_init:
		var enemy_instance = enemy_scene.instantiate()
		
		if event["type"] == "xuanwu":
			enemy_instance.on_boss_died.connect(_on_boss_died)
			enemy_instance.set_hp_bar(boss_hp_bar)
		elif event["type"] == "shoot_2":
			enemy_instance.mode = int(event["args"])
		elif event["type"] == "support":
			enemy_instance.mode = int(event["args"])

		enemy_instance.position = event["position"]
		get_parent().add_child(enemy_instance)

func append_enemy(time_line: float, _type: String, position: Vector2, enemy_arg: String):
	spawn_schedule.append({
		"time": time_line,
		"type": _type,
		"position": position,
		"args": enemy_arg
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
	var lines = content.split("\n", false)
	for line in lines:
		if line.is_empty() or line == "\r" or line.begins_with("#"):
			continue
		var columns = line.split(",")
		if columns.size() > 4:
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
			var enemy_arg = ""
			if columns.size() == 4:
				enemy_arg = columns[3]
			append_enemy(time, type, position, enemy_arg)

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
		#audio_player.volume_db = -10
		start_time = Time.get_ticks_msec() / 1000.0 - paused_time
		print("Enemy spawning resumed")

func stop():
	is_running = false
	is_paused = false
	paused_time = 0.0
	start_time = 0.0
	spawn_index = 0
	print("Enemy spawning stopped and reset")

func _on_boss_died():
	audio_player.stop()
	get_parent().on_boss_died()

func fade_out_audio(duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80, duration).as_relative()
	tween.tween_callback(Callable(audio_player, "stop"))

func show_warning(duration: float = 1.0) -> void:
	var warning_instance = warning_scene.instantiate()
	get_tree().current_scene.add_child(warning_instance)
	var viewport_size = get_viewport().get_visible_rect().size
	warning_instance.position = viewport_size / 2
	await get_tree().create_timer(duration).timeout
	warning_instance.queue_free()
