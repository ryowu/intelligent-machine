extends Node2D
@onready var player_1: Area2D = $Player1

func _ready():
	player_1.position = Vector2(80, 300)
