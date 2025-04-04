extends Control

@export var talking_script: Array = [
	{"sentence": "前方大批敌人出现，请做好出击准备", "voice_path": "res://assets/voice/stage1/stage1_1.mp3"},
	{"sentence": "记得使用副武器，它可以提供有效的帮助", "voice_path": "res://assets/voice/stage1/stage1_2.mp3"},
	{"sentence": "最后一定要安全回来哦", "voice_path": "res://assets/voice/stage1/stage1_3.mp3"}
]

@onready var lbl_text: Label = $Panel/lbl_bg
var current_sentence_index: int = 0
var is_talking: bool = false
var audio_player: AudioStreamPlayer

signal dialog_ended

func _ready():
	visible = false
	lbl_text.text = ""
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("ui_accept"):
		show_next_sentence()

func start_dialog():
	visible = true
	is_talking = true
	current_sentence_index = 0
	show_next_sentence()

func stop_dialog():
	audio_player.stop()
	visible = false
	is_talking = false
	lbl_text.text = ""
	dialog_ended.emit()

func show_next_sentence():
	if current_sentence_index == talking_script.size():
		wait_for_ui_accept_to_close()

	if current_sentence_index < talking_script.size():
		lbl_text.text = talking_script[current_sentence_index]["sentence"]
		play_voice(talking_script[current_sentence_index]["voice_path"])
		current_sentence_index += 1
	else:
		is_talking = false
		lbl_text.text = "Press to close the dialog."

func play_voice(voice_path: String):
	var audio_stream = load(voice_path)
	if audio_stream:
		audio_player.stream = audio_stream
		audio_player.play()

func wait_for_ui_accept_to_close():
	if Input.is_action_just_pressed("ui_accept"):
		stop_dialog()
