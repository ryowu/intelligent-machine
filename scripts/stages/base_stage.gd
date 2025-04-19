extends Node2D

@onready var lbl_life: Label = $ui_panel/VBoxContainer/HBox_top/lbl_life
@onready var lbl_score: Label = $ui_panel/VBoxContainer/HBox_top/lbl_score
@onready var lbl_speed: Label = $ui_panel/VBoxContainer/HBoxContainer/lbl_speed
@onready var lbl_power: Label = $ui_panel/VBoxContainer/HBoxContainer/lbl_power
@onready var lbl_side_power: Label = $ui_panel/VBoxContainer/HBoxContainer/lbl_side_power
@onready var stage_clear_panel: Control = $stage_clear_panel

@onready var scheduler: Node2D = $scheduler
@onready var dialog: Control = $dialog
@onready var stage_complete_bgm: AudioStreamPlayer2D = $stage_complete_bgm

signal on_stage_dialog_end()
var player_scene_path = ""
var player_1: Area2D
var next_scene = ""

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GlobalManager.new_stage()

	if GlobalManager.charactor_name == "Yunfeng":
		init_player("res://scene/moving_objects/player_silver_shark.tscn")
	elif GlobalManager.charactor_name == "Xiaoai":
		init_player("res://scene/moving_objects/player_pinky.tscn")
	
	scheduler.on_dialog_start.connect(_on_dialog_start)
	dialog.dialog_ended.connect(_on_dialog_ended)
	GlobalManager.score_updated.connect(update_score_label)
	scheduler.start()

func init_player(scene_path: String) -> void:
	player_scene_path = scene_path

	var player_scene = load(scene_path)
	player_1 = player_scene.instantiate()
	player_1.name = GlobalConfig.PLAYER_NODE_NAME
	player_1.position = Vector2(-300, 300)
	add_child(player_1)

	player_1.on_power_change.connect(_on_power_change)
	player_1.on_side_power_change.connect(_on_side_power_change)
	player_1.on_speed_change.connect(_on_speed_change)
	player_1.on_player_die.connect(_on_player_die)

	# Set player_body_sprite transparent
	var body_sprite = player_1.get_node("player_body_sprite")
	if body_sprite is Sprite2D:
		body_sprite.modulate.a = 0.5


func update_score_label(new_score):
	lbl_score.text = "分数: " + str(new_score)

func _on_dialog_ended():
	player_1.suspending = false
	scheduler.resume()
	on_stage_dialog_end.emit()

func _on_dialog_start(dialog_name: String):
	dialog.start_dialog(dialog_name)
	player_1.suspending = true

func on_boss_died():
	player_1.suspending = true
	stage_complete_bgm.play()
	stage_clear_panel.next_scene = next_scene
	stage_clear_panel.update_view()
	stage_clear_panel.visible = true
	stage_clear_panel.launch_sum_up()

func _on_power_change(new_power):
	if new_power == 4:
		lbl_power.text = "主武器：MAX"
	else:
		lbl_power.text = "主武器：" + str(new_power)

func _on_side_power_change(new_side_power):
	if new_side_power == 2:
		lbl_side_power.text = "副武器：MAX"
	else:
		lbl_side_power.text = "副武器：" + str(new_side_power)

func _on_speed_change(new_speed):
	if new_speed == 4:
		lbl_speed.text = "速度：MAX"
	else:
		lbl_speed.text = "速度：" + str(new_speed)

func _on_player_die(new_life: int):
	if new_life > 0:
		lbl_life.text = "战机数：" + str(new_life)
		player_1.queue_free()
		await get_tree().process_frame
		init_player(player_scene_path)
	else:
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://scene/sys/main_menu.tscn")
