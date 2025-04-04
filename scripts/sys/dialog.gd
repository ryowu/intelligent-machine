extends Control

@onready var lbl_text: Label = $Panel/lbl_bg
var dialog_script = load("res://scripts/sys/talking_scripts.gd") as Script
var script_instance = dialog_script.new()
var current_sentence_index: int = 0
var is_talking: bool = false
var audio_player: AudioStreamPlayer
var talking_script: Array = []
signal dialog_ended

func _ready():
	visible = false
	lbl_text.text = ""
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func _process(_delta):
	if is_talking and Input.is_action_just_pressed("ui_accept"):
		show_next_sentence()

func start_dialog(dialog_name: String):
	if dialog_script:
		var script_variable = script_instance.get(dialog_name)
		if typeof(script_variable) == TYPE_ARRAY:
			talking_script = script_variable
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
	if audio_player.playing:
		return
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
