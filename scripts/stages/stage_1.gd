extends Node2D

@onready var player_1: Area2D = $Player1
@onready var lbl_score: Label = $ui_panel/VBoxContainer/lbl_score
@onready var lbl_speed: Label = $ui_panel/VBoxContainer/lbl_speed
@onready var lbl_power: Label = $ui_panel/VBoxContainer/lbl_power
@onready var lbl_side_power: Label = $ui_panel/VBoxContainer/lbl_side_power

@onready var scheduler: Node2D = $scheduler
@onready var dialog: Control = $dialog
@onready var stage_complete_bgm: AudioStreamPlayer2D = $stage_complete_bgm

signal on_stage_dialog_end()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	scheduler.on_dialog_start.connect(_on_dialog_start)
	dialog.dialog_ended.connect(_on_dialog_ended)
	GlobalManager.score_updated.connect(update_score_label)
	player_1.on_power_change.connect(_on_power_change)
	player_1.on_side_power_change.connect(_on_side_power_change)
	player_1.on_speed_change.connect(_on_speed_change)
	player_1.position = Vector2(80, 300)
	scheduler.start()

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
