extends "res://scripts/planes/base_shootable_enemy.gd"
	
func _ready() -> void:
	super._ready()
	fireball_timer.start()
