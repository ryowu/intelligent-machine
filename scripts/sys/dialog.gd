extends Control
@onready var char_avatar: Sprite2D = $Panel/char_avatar
@onready var lbl_text: Label = $Panel/lbl_bg
var dialog_script = load("res://scripts/sys/talking_scripts.gd") as Script
var script_instance = dialog_script.new()
var current_sentence_index: int = 0
var is_talking: bool = false
var audio_player: AudioStreamPlayer
var talking_script: Array = []
var dialog_input_blocked: bool = false

signal dialog_ended

func _ready():
	visible = false
	lbl_text.text = ""
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func _process(_delta):
	if is_talking and not dialog_input_blocked and Input.is_action_just_pressed("ui_accept"):
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
			dialog_input_blocked = true
			await get_tree().create_timer(0.5).timeout
			dialog_input_blocked = false

func stop_dialog():
	audio_player.stop()
	visible = false
	is_talking = false
	lbl_text.text = ""
	dialog_ended.emit()

func show_next_sentence():
	if current_sentence_index == talking_script.size():
		wait_for_ui_accept_to_close()
		return

	if current_sentence_index < talking_script.size():
		var char_name = talking_script[current_sentence_index]["char"]
		lbl_text.text = talking_script[current_sentence_index]["sentence"]
		if char_name.begins_with("@") and char_name.substr(1) != GlobalManager.charactor_name:
			current_sentence_index += 1
			show_next_sentence()
		else:
			play_voice(talking_script[current_sentence_index]["voice_path"])
			if char_name.begins_with("@"):
				char_name = char_name.substr(1)
			update_avatar(char_name)
			current_sentence_index += 1
	else:
		is_talking = false
		lbl_text.text = "Press to close the dialog."

func update_avatar(char_name: String):
	var avatar_path = "res://assets/img/avatar/%s.png" % char_name
	var avatar_texture = load(avatar_path) as Texture2D
	if avatar_texture:
		char_avatar.texture = avatar_texture

func play_voice(voice_path: String):
	var audio_stream = load(voice_path)
	if audio_stream:
		audio_player.stream = audio_stream
		audio_player.play()

func wait_for_ui_accept_to_close():
	if Input.is_action_just_pressed("ui_accept"):
		stop_dialog()
