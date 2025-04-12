extends Node2D

signal score_updated(new_score)

var score: int = 0
var player_skill_amount = 3
var skill_progress: int = 100
var skill_timer: Timer

signal on_skill_ready(bool)
signal on_skill_progressed(int)

func _ready() -> void:
	skill_timer = Timer.new()
	skill_timer.wait_time = 0.2
	skill_timer.autostart = true
	skill_timer.one_shot = false
	skill_timer.timeout.connect(skill_timer_timeout)
	get_tree().root.call_deferred("add_child", skill_timer)

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
