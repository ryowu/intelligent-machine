extends Node2D
@onready var btn_start: Button = $Control/VBoxContainer/btn_start
@onready var btn_exit: Button = $Control/VBoxContainer/btn_exit
@onready var button_confirm: AudioStreamPlayer2D = $button_confirm

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GlobalManager.play_bgm(0)
	btn_start.grab_focus()

func _on_btn_start_pressed() -> void:
	GlobalManager.disable_all_buttons(get_tree().current_scene)
	GlobalManager.new_game()
	button_confirm.play()
	await button_confirm.finished
	get_tree().change_scene_to_file("res://scene/sys/select_player.tscn")

func _on_btn_exit_pressed() -> void:
	get_tree().quit()
