extends Node2D

const ENEMY_NORMAL = preload("res://scene/planes/enemy_normal_1.tscn")
const ENEMY_SUPPORT = preload("res://scene/planes/enemy_support.tscn")
@onready var bgm: AudioStreamPlayer2D = $bgm

@export var spawn_rate = 3.0  # Time interval for spawning enemies
@export var spawn_y_range = Vector2(50, 300)  # Adjust based on your screen height
var enemies_in_row = 5

func _ready():
	# Timer for spawning normal enemies
	var normal_enemy_timer = Timer.new()
	normal_enemy_timer.wait_time = spawn_rate
	normal_enemy_timer.autostart = true
	normal_enemy_timer.timeout.connect(_spawn_enemy)
	add_child(normal_enemy_timer)

func _spawn_enemy():
	#var viewport_size = get_viewport().get_visible_rect().size
	#var new_y = randf_range(spawn_y_range.x, spawn_y_range.y)
	#for i in range(enemies_in_row):
		#var enemy = ENEMY_NORMAL.instantiate()
		#enemy.hp = 1
		#enemy.position = Vector2(viewport_size.x + i * 150, new_y)
		#get_parent().add_child(enemy)
	pass
