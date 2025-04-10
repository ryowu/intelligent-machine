extends Control
@onready var skill_1: TextureRect = $HBoxContainer/skill1
@onready var skill_2: TextureRect = $HBoxContainer/skill2
@onready var skill_3: TextureRect = $HBoxContainer/skill3
@onready var lbl_cool_down: Label = $HBoxContainer/lbl_cool_down
@onready var accumulate: ProgressBar = $HBoxContainer/accumulate
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	refresh_skill_amount()
	accumulate.value = 100
	lbl_cool_down.text = "可发动"
	GlobalManager.on_skill_ready.connect(_on_skill_ready)
	GlobalManager.on_skill_progressed.connect(_on_skill_progressed)
	refresh_skill_amount()

func refresh_skill_amount():
	if GlobalManager.player_skill_amount > 0:
		accumulate.visible = true
		lbl_cool_down.visible = true
	else:
		accumulate.visible = false
		lbl_cool_down.visible = false
		
	if GlobalManager.player_skill_amount == 3:
		skill_1.visible = true
		skill_2.visible = true
		skill_3.visible = true
	elif GlobalManager.player_skill_amount == 2:
		skill_1.visible = true
		skill_2.visible = true
		skill_3.visible = false
	elif GlobalManager.player_skill_amount == 1:
		skill_1.visible = true
		skill_2.visible = false
		skill_3.visible = false
	else:
		skill_1.visible = false
		skill_2.visible = false
		skill_3.visible = false

func _on_skill_ready(is_ready):
	if is_ready:
		lbl_cool_down.text = "可发动"
		animation_player.play("skill_ready")
	else:
		lbl_cool_down.text = "冷却中"
		animation_player.stop()
	refresh_skill_amount()
		
func _on_skill_progressed(new_value):
	accumulate.value = new_value
