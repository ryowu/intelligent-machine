extends Node2D
@onready var player_1: Area2D = $Player1
@onready var lbl_score: Label = $ui_panel/lbl_score
@onready var spawner: Node2D = $spawner

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	GlobalManager.score_updated.connect(update_score_label)
	player_1.position = Vector2(80, 300)
	spawner.start()

func update_score_label(new_score):
	lbl_score.text = "分数: " + str(new_score)
