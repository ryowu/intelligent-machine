extends "res://scripts/planes/base_player_bullet.gd"

var bullet_mode := 3

const BULLET_IMAGES = {
	1: preload("res://assets/img/planes/player/player_bullet_lg.png"),
	2: preload("res://assets/img/planes/player/player_bullet_single.png"),
	3: preload("res://assets/img/planes/player/player_bullet_sm.png")
}

func _ready():
	super._ready()
	sprite.texture = BULLET_IMAGES.get(bullet_mode, BULLET_IMAGES[1])
