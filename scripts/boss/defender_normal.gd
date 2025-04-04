extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
enum BossPhase { PHASE1, PHASE2, PHASE3 }
var current_phase = BossPhase.PHASE1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var shooting_timer: Timer = $ShootingTimer
@onready var player: Area2D = get_node("/root/stage1/Player1")

@export var max_health: int = 100
var hp_bar: ProgressBar = null
var health: int = max_health
var dying = false

var fireball_scene: PackedScene = preload("res://scene/planes/enemy_fireball_sm.tscn")

signal on_boss_died

func _ready():
	get_parent().on_stage_dialog_end.connect(_on_dialog_end)
	animation_player.play("enter_field")
	await animation_player.animation_finished
	shooting_timer.timeout.connect(_on_shooting_timer_timeout)

func start_phase(phase):
	current_phase = phase
	match phase:
		BossPhase.PHASE1:
			animated_sprite_2d.play("idle")
			shooting_timer.start(1.2)
		BossPhase.PHASE2:
			animated_sprite_2d.play("shoot_normal")
			shooting_timer.start(0.8)
		BossPhase.PHASE3:
			animated_sprite_2d.play("shoot_normal")
			shooting_timer.start(0.2)

func _on_shooting_timer_timeout():
	match current_phase:
		BossPhase.PHASE1:
			shoot_toward_player()
		BossPhase.PHASE2:
			shoot_spread(3, 15)
		BossPhase.PHASE3:
			shoot_rain(5)

# Shoot directly at the player
func shoot_toward_player():
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.position = position
	var dir = (player.global_position - fireball.position).normalized()
	fireball.set_velocity(dir * 200)

# Shoot multiple bullets in a spread pattern
func shoot_spread(count: int, angle_step: float):
	for i in range(count):
		var angle = -angle_step * (count - 1) / 2 + i * angle_step
		var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
		var fireball = fireball_scene.instantiate()
		get_parent().add_child(fireball)
		fireball.position = position
		fireball.set_velocity(dir * 200)

# Rain bullets vertically
func shoot_rain(count: int):
	for i in range(count):
		var fireball = fireball_scene.instantiate()
		get_parent().add_child(fireball)
		var offset = Vector2(i * 40 - (count / 2) * 40, 0)
		fireball.position = position + offset
		fireball.set_velocity(Vector2.DOWN * 250)

func take_damage(amount: int):
	health -= amount
	hp_bar.value = health
	if current_phase == BossPhase.PHASE1 and health <= 70:
		start_phase(BossPhase.PHASE2)
	elif current_phase == BossPhase.PHASE2 and health <= 30:
		start_phase(BossPhase.PHASE3)

	if health <= 0:
		die()

func die():
	shooting_timer.stop()
	hp_bar.visible = false
	hp_bar = null
	dying = true
	on_boss_died.emit()
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if !dying and area.is_in_group("player_bullet"):
		area.queue_free()
		take_damage(1)

func _on_dialog_end():
	start_phase(BossPhase.PHASE1)

func set_hp_bar(_hp_bar: ProgressBar):
	hp_bar = _hp_bar
	hp_bar.visible = true
	hp_bar.max_value = health
	hp_bar.min_value = 0
