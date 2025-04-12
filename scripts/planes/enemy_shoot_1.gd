extends "res://scripts/planes/base_shootable_enemy.gd"
	
func _ready() -> void:
	super._ready()
	hp = 4
	speed = 150
	score = 150
	coin_count = 1
	fireball_timer.start()
