extends Node2D
@onready var btn_start: Button = $Control/VBoxContainer/btn_start
@onready var btn_exit: Button = $Control/VBoxContainer/btn_exit

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	btn_start.grab_focus()


func _on_btn_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/stages/stage_1.tscn")


func _on_btn_exit_pressed() -> void:
	get_tree().quit()
