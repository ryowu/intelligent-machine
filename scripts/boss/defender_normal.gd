extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
enum BossPhase { PHASE1, PHASE2, PHASE3 }
var current_phase = BossPhase.PHASE1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shooting_timer: Timer = $ShootingTimer
@onready var player: Area2D = get_parent().get_node(GlobalConfig.PLAYER_NODE_NAME)

@export var max_health: int = 1000
var hp_bar: ProgressBar = null
var health: int = max_health
var dying = false

var even_counter = 0

var fireball_scene: PackedScene = preload("res://scene/planes/enemy_fireball_sm.tscn")

signal on_boss_died

func _ready():
	get_parent().on_stage_dialog_end.connect(_on_dialog_end)
	collision_shape_2d.disabled = true
	animation_player.play("enter_field")
	await animation_player.animation_finished
	shooting_timer.timeout.connect(_on_shooting_timer_timeout)

func get_even_counter() -> int:
	even_counter += 1
	if even_counter > 1:
		even_counter = 0
	return even_counter

func start_phase(phase):
	current_phase = phase
	even_counter = 0
	match phase:
		BossPhase.PHASE1:
			animated_sprite_2d.play("idle")
			shooting_timer.start(1)
		BossPhase.PHASE2:
			animated_sprite_2d.play("shoot_normal")
			shooting_timer.start(0.5)
		BossPhase.PHASE3:
			animated_sprite_2d.play("shoot_normal")
			shooting_timer.start(0.8)

func _on_shooting_timer_timeout():
	match current_phase:
		BossPhase.PHASE1:
			shoot_toward_player()
		BossPhase.PHASE2:
			shoot_spread(5, 10)
		BossPhase.PHASE3:
			shoot_rain(10, 7)

# Shoot directly at the player
func shoot_toward_player():
	if get_even_counter() == 0:
		var fireball = fireball_scene.instantiate()
		get_parent().add_child(fireball)
		fireball.position = position
		fireball.speed = 400
		var dir = (player.global_position - fireball.position).normalized()
		fireball.set_velocity(dir * 200)
	else:
		for i in range(4):
			var angle = -15 + i * 10
			var dir2 = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball2 = fireball_scene.instantiate()
			get_parent().add_child(fireball2)
			fireball2.position = position
			fireball2.set_velocity(dir2 * 200)

# Shoot multiple bullets in a spread pattern
func shoot_spread(count: int, angle_step: float):
	if get_even_counter() == 0:
		for i in range(count):
			var angle = -angle_step * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.set_velocity(dir * 200)
	else:
		for i in range(count):
			var angle = -2.0 * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.set_velocity(dir * 200)

# Rain bullets vertically
func shoot_rain(count, angle_step: float):
	if get_even_counter() == 0:
		var fireball0 = fireball_scene.instantiate()
		get_parent().add_child(fireball0)
		fireball0.position = position
		fireball0.speed = 400
		var dir0 = (player.global_position - fireball0.position).normalized()
		fireball0.set_velocity(dir0 * 200)

		for i in range(count):
			var angle = -angle_step * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.speed = 100
			fireball.set_velocity(dir * 200)
	else:
		for i in range(count):
			var angle = -2 * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.speed = 100
			fireball.set_velocity(dir * 200)

func take_damage(amount: int):
	health -= amount
	hp_bar.value = health
	if current_phase == BossPhase.PHASE1 and health <= 700:
		start_phase(BossPhase.PHASE2)
	elif current_phase == BossPhase.PHASE2 and health <= 400:
		start_phase(BossPhase.PHASE3)

	if health <= 0:
		die()

func die():
	shooting_timer.stop()
	hp_bar.visible = false
	hp_bar = null
	dying = true
	clear_field()
	on_boss_died.emit()
	queue_free()

func do_hurt(area: Area2D, keep_original = false):
	if !keep_original:
		area.queue_free()
	take_damage(area.damage)

func _on_dialog_end():
	collision_shape_2d.disabled = false
	start_phase(BossPhase.PHASE1)

func set_hp_bar(_hp_bar: ProgressBar):
	hp_bar = _hp_bar
	hp_bar.visible = true
	hp_bar.max_value = health
	hp_bar.min_value = 0

func clear_field():
	for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
		bullet.queue_free()


func _on_area_entered(area: Area2D) -> void:
	if !dying and area.is_in_group("player_bullet"):
		do_hurt(area)
