extends "res://scripts/planes/base_player_bullet.gd"

func _ready() -> void:
	super._ready()
	damage = GlobalConfig.BASIC_PLAYER_CHILD_BULLET_DAMAGE
