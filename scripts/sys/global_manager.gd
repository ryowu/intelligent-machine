extends Node2D
@onready var bgm_player: AudioStreamPlayer2D = $bgm_player
@onready var skill_timer: Timer = $skill_timer

signal score_updated(new_score)

var bgms = [
	"res://assets/music/main_menu.mp3",
	""
]

var score: int = 0
var player_skill_amount = 3
var skill_progress: int = 100
var charactor_name = "Yunfeng"
var coin_count = 0

signal on_skill_ready(bool)
signal on_skill_progressed(int)

func _ready() -> void:
	skill_timer.wait_time = 0.2
	skill_timer.one_shot = false
	skill_timer.timeout.connect(skill_timer_timeout)
	skill_timer.start()

func new_game():
	pass

func new_stage():
	coin_count = 0

func add_coin():
	coin_count += 1

func add_score(amount: int):
	score += amount
	score_updated.emit(score)

func skill_timer_timeout():
	if skill_progress > 100:
		skill_progress = 100
		if player_skill_amount >= 1:
			on_skill_ready.emit(true)
	else:
		skill_progress += 1
	
	on_skill_progressed.emit(skill_progress)
	
func use_skill():
	if player_skill_amount > 0:
		skill_progress = 0
		player_skill_amount -= 1
		on_skill_ready.emit(false)

func play_bgm(bgm_index: int):
	if bgm_player.playing:
		bgm_player.stop()
	
	var stream_path = bgms[bgm_index]
	var audio_stream = load(stream_path)
	if audio_stream:
		bgm_player.stream = audio_stream
		bgm_player.play()
		
func stop_bgm():
	if bgm_player.playing:
		bgm_player.stop()

func disable_all_buttons(root: Node = get_tree().current_scene) -> void:
	for button in root.get_children():
		if button is Button:
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE
		elif button.has_method("get_children"):
			disable_all_buttons(button)
