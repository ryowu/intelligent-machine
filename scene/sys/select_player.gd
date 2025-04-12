extends Node2D
@onready var yunfeng: Button = $Control/HBoxContainer/yunfeng
@onready var xiaoai: Button = $Control/HBoxContainer/xiaoai
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var select_char_audio: AudioStreamPlayer2D = $select_char_audio
@onready var lbl_description: Label = $description/Panel/lbl_description

var is_focused = false

const yunfeng_description = "云峰（Yunfeng）
空军中校，年龄30，作战经验丰富
多次执行高危任务，冷静果断
擅长指挥与战术规划，是团队核心
内心坚毅，沉稳可靠，战友信赖的领袖
誓为人类守护最后一道防线"

const xiaoai_description = "小爱（Xiao Ai）
年仅十八岁的天才少女，空军少校
拥有惊人反应力和直觉，战斗本能出众
性格开朗，活泼可爱，却从不掉以轻心
驾驶技术娴熟，常以不按常理出牌取胜
在战火中绽放的青春之光"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	yunfeng.grab_focus()


func _on_yunfeng_pressed() -> void:
	GlobalManager.stop_bgm()
	GlobalManager.charactor_name = "yunfeng"
	get_tree().change_scene_to_file("res://scene/stages/stage_1.tscn")


func _on_xiaoai_pressed() -> void:
	GlobalManager.stop_bgm()
	GlobalManager.charactor_name = "xiaoai"
	get_tree().change_scene_to_file("res://scene/stages/stage_1.tscn")


func _on_yunfeng_focus_entered() -> void:
	if is_focused:
		select_char_audio.play()
		animation_player.play("change_char_to_yunfeng")
		lbl_description.text = yunfeng_description
	else:
		is_focused = true

func _on_xiaoai_focus_entered() -> void:
	select_char_audio.play()
	animation_player.play_backwards("change_char_to_yunfeng")
	lbl_description.text = xiaoai_description
