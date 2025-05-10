extends Node2D

@onready var yunfeng: Button = $Control/HBoxContainer/yunfeng
@onready var xiaoai: Button = $Control/HBoxContainer/xiaoai
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var select_char_audio: AudioStreamPlayer2D = $select_char_audio
@onready var lbl_description: Label = $description/Panel/lbl_description
@onready var lbl_plane_description: Label = $description_plane/Panel_plane/lbl_plane_description
@onready var player_voice: AudioStreamPlayer2D = $player_voice
@onready var button_confirm: AudioStreamPlayer2D = $button_confirm
@onready var button_cancel: AudioStreamPlayer2D = $button_cancel

var is_focused = false
var yunfeng_voice_index := 0
var xiaoai_voice_index := 0
const first_stage = "res://scene/stages/stage_3.tscn"

const yunfeng_description = "云峰（Yunfeng）\n空军上校，年龄30，作战经验丰富\n多次执行高危任务，冷静果断\n擅长指挥与战术规划，是团队核心\n内心坚毅，沉稳可靠，战友信赖的领袖\n誓为人类守护最后一道防线"
const silver_shark_description = "机体：银鲨号
必杀技：援护小队
特点：大范围的子弹覆盖以及
小队支援使得作战安全性大大提高"

const xiaoai_description = "小爱（Xiao Ai）\n年仅十八岁的天才少女，空军少校\n拥有惊人反应力和直觉，战斗本能出众\n性格开朗，活泼可爱，却从不掉以轻心\n驾驶技术娴熟，常以不按常理出牌取胜\n在战火中绽放的青春之光"
const pinky_description = "机体：樱梦号
必杀技：缩退炮
特点：和可爱的外表相反
这架机体搭载了重伤害武器
"

const yunfeng_voice = [
	"res://assets/voice/select_chars/yunfeng_s1.mp3",
	"res://assets/voice/select_chars/yunfeng_s2.mp3",
	"res://assets/voice/select_chars/yunfeng_s3.mp3"
]
const yunfeng_start_voice = "res://assets/voice/select_chars/yunfeng_start.mp3"

const xiaoai_voice = [
	"res://assets/voice/select_chars/xiaoai_s1.mp3",
	"res://assets/voice/select_chars/xiaoai_s2.mp3",
	"res://assets/voice/select_chars/xiaoai_s3.mp3"
]
const xiaoai_start_voice = "res://assets/voice/select_chars/xiaoai_start.mp3"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	yunfeng.grab_focus()


func _on_yunfeng_pressed() -> void:
	GlobalManager.disable_all_buttons(get_tree().current_scene)
	button_confirm.play()
	await button_confirm.finished
	GlobalManager.stop_bgm()
	GlobalManager.charactor_name = "Yunfeng"
	await play_voice(yunfeng_start_voice, true)
	load_stage_1()

func _on_xiaoai_pressed() -> void:
	GlobalManager.disable_all_buttons(get_tree().current_scene)
	button_confirm.play()
	await button_confirm.finished
	GlobalManager.stop_bgm()
	GlobalManager.charactor_name = "Xiaoai"
	await play_voice(xiaoai_start_voice, true)
	load_stage_1()

func load_stage_1():
	get_tree().change_scene_to_file(first_stage)

func _on_yunfeng_focus_entered() -> void:
	_play_next_voice(yunfeng_voice, "yunfeng")
	if is_focused:
		select_char_audio.play()
		animation_player.play("change_char_to_yunfeng")
		lbl_description.text = yunfeng_description
		lbl_plane_description.text = silver_shark_description
		_play_next_voice(yunfeng_voice, "yunfeng")
	else:
		is_focused = true


func _on_xiaoai_focus_entered() -> void:
	select_char_audio.play()
	animation_player.play_backwards("change_char_to_yunfeng")
	lbl_description.text = xiaoai_description
	lbl_plane_description.text = pinky_description
	_play_next_voice(xiaoai_voice, "xiaoai")

func _play_next_voice(voice_array: Array, who: String) -> void:
	await get_tree().create_timer(0.2).timeout
	var index = 0
	if who == "yunfeng":
		index = yunfeng_voice_index
		yunfeng_voice_index = (yunfeng_voice_index + 1) % voice_array.size()
	elif who == "xiaoai":
		index = xiaoai_voice_index
		xiaoai_voice_index = (xiaoai_voice_index + 1) % voice_array.size()
	
	var path = voice_array[index]
	play_voice(path)

func play_voice(path: String, _await = false):
	var stream = load(path)
	if stream:
		player_voice.stop()
		player_voice.stream = stream
		player_voice.play()
		if _await:
			await player_voice.finished
