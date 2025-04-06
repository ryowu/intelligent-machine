extends "res://scripts/planes/base_route_enemy.gd"

@export var fireball_speed = 380
@export var fireball_shoot_interval = 2.5
var fireball_scene: PackedScene = preload("res://scene/planes/enemy_fireball_sm.tscn")
var fireball_timer: Timer

func _ready():
	fireball_timer = Timer.new()
	add_child(fireball_timer)
	fireball_timer.wait_time = fireball_shoot_interval
	fireball_timer.one_shot = false
	fireball_timer.timeout.connect(_on_fireball_timer_timeout)

func _on_fireball_timer_timeout():
	if dying: 
		return
	shoot_fireball()

func shoot_fireball():
	var fireball = fireball_scene.instantiate()
	fireball.position = position
	get_parent().add_child(fireball)
	
func _disable_enemy():
	fireball_timer.stop()
	super._disable_enemy()
