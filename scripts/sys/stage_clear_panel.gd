extends Control

@onready var lbl_coins: Label = $CenterContainer/VBoxContainer/lbl_coins
@onready var lbl_coin_score: Label = $CenterContainer/VBoxContainer/lbl_coin_score
@onready var collect_coin: AudioStreamPlayer2D = $collect_coin
@onready var cash_registry: AudioStreamPlayer2D = $cash_registry

var summury_end = false
var next_scene = ""

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if summury_end and Input.is_action_just_pressed("ui_accept"):
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)

func update_view():
	lbl_coins.text = "收集金币：" + str(GlobalManager.coin_count)
	lbl_coin_score.text = "奖励分数：0"

func launch_sum_up() -> void:
	visible = true
	await get_tree().create_timer(1).timeout

	var bonus_score = 0
	for i in GlobalManager.coin_count:
		bonus_score += 100
		lbl_coin_score.text = "奖励分数：" + str(bonus_score)
		collect_coin.play()
		await get_tree().create_timer(0.2).timeout

	cash_registry.play()
	await cash_registry.finished
	GlobalManager.add_score(bonus_score)
	summury_end = true
