extends Node2D
@onready var player_1: Area2D = $Player1
@onready var lbl_score: Label = $ui_panel/lbl_score

func _ready():
	GlobalManager.score_updated.connect(update_score_label)
	player_1.position = Vector2(80, 300)

func update_score_label(new_score):
	lbl_score.text = "分数: " + str(new_score)
