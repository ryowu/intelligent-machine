extends Node2D

@onready var player_1: Area2D = $Player1
@onready var lbl_score: Label = $ui_panel/lbl_score
@onready var scheduler: Node2D = $scheduler
@onready var dialog: Control = $dialog
@onready var stage_complete_bgm: AudioStreamPlayer2D = $stage_complete_bgm

signal on_stage_dialog_end()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	scheduler.on_dialog_start.connect(_on_dialog_start)
	dialog.dialog_ended.connect(_on_dialog_ended)
	GlobalManager.score_updated.connect(update_score_label)
	
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
