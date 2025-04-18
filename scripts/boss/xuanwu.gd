extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var player: Area2D = get_parent().get_node(GlobalConfig.PLAYER_NODE_NAME)
@export var max_health: int = 1000

var fireball_scene_sm: PackedScene = preload("res://scene/planes/enemy_fireball_sm.tscn")
var fireball_scene_md: PackedScene = preload("res://scene/planes/enemy_fireball_md.tscn")

var hp_bar: ProgressBar = null
var health: int = max_health
var dying = false

var even_counter = 0

enum BossPhase {PHASE0, PHASE1, PHASE2, PHASE3}
var current_phase = BossPhase.PHASE0
var current_path_index = 0
var current_action = {}
var reached_position = false
var speed = 300
var paused = false

var phase0_path = [
	{ "target": Vector2(900, 320), "call": "", "dynamic_position": "" }
]

var phase1_path = [
	{ "target": Vector2(900, 120), "call": "shoot_toward_player", "dynamic_position": "" },
	{ "target": Vector2(900, 320), "call": "shoot_toward_player", "dynamic_position": "" },
	{ "target": Vector2(900, 520), "call": "shoot_toward_player", "dynamic_position": "" },
	{ "target": Vector2(900, 300), "call": "shoot_toward_player", "dynamic_position": "" }
]

var phase2_path = [
	{ "target": Vector2(900, 320), "call": "prepare_to_rush", "dynamic_position": "" },
	{ "target": null, "call": "player_position_reached", "dynamic_position": "player" },
	{ "target": Vector2(900, 320), "call": "wait_and_shoot", "dynamic_position": "" }
]

var player_locked = false

signal on_boss_died

func _ready():
	player.power_level = 4
	player.speed_level = 2
	player.side_weapon_level = 2
	get_parent().on_stage_dialog_end.connect(_on_dialog_end)
	collision_shape_2d.disabled = true
	start_phase(BossPhase.PHASE0)

func _process(delta):
	if paused: return
	if current_action.dynamic_position == "player" and !player_locked:
		player_locked = true
		current_action.target = player.position

	var direction = (current_action.target - global_position).normalized()
	var distance = (current_action.target - global_position).length()

	if distance > speed * delta:
		global_position += direction * speed * delta
	else:
		global_position = current_action.target
		if not reached_position:
			reached_position = true
			if current_action.call != "":
				paused = true
				await call(current_action.call)
				paused = false
			advance_to_next_path_point()

func get_even_counter() -> int:
	even_counter += 1
	if even_counter > 1:
		even_counter = 0
	return even_counter

# region: Phase 2 actions
func prepare_to_rush():
	await get_tree().create_timer(0.5).timeout
	animated_sprite_2d.flip_h = false
	animated_sprite_2d.play("rush")
	await get_tree().create_timer(0.5).timeout

func player_position_reached():
	player_locked = false
	animated_sprite_2d.flip_h = true

func wait_and_shoot():
	animated_sprite_2d.play("idle")
	animated_sprite_2d.flip_h = false
	await get_tree().create_timer(0.5).timeout
	await shoot_half_round()
	await get_tree().create_timer(1.0).timeout
	await shoot_spread_multi(3, 25, 700)
	await get_tree().create_timer(0.2).timeout
	await shoot_spread_multi(2, 25, 600)
	await get_tree().create_timer(0.2).timeout
	await shoot_spread_multi(1, 10, 500)

func shoot_half_round():
	var start_angle = -80
	var end_angle = 80
	var angle_step = 10

	var up_angles = range(start_angle, end_angle + 1, angle_step)
	var down_angles = range(end_angle, start_angle - 1, -angle_step)

	for repeat in range(2):  # Repeat the entire sequence twice
		for i in range(min(up_angles.size(), down_angles.size())):
			var angle_up = deg_to_rad(up_angles[i])
			var angle_down = deg_to_rad(down_angles[i])

			# Fireball shooting upward (bottom to top)
			var fireball_up = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball_up)
			set_bullet_position(fireball_up)
			fireball_up.set_velocity(Vector2.LEFT.rotated(angle_up).normalized() * 200)

			# Fireball shooting downward (top to bottom)
			var fireball_down = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball_down)
			set_bullet_position(fireball_down)
			fireball_down.set_velocity(Vector2.LEFT.rotated(angle_down).normalized() * 200)

			await get_tree().create_timer(0.1).timeout

func shoot_spread_multi(count: int, angle: float, _speed: float):
	if player == null:
		return

	var fireball_origin = position
	var direction_to_player = (player.global_position - fireball_origin).normalized()
	var base_angle = direction_to_player.angle()  # In radians

	var total_angle = deg_to_rad(angle)
	var half_count = (count - 1) / 2.0  # Can be fractional for even counts

	for i in range(count):
		var offset = i - half_count
		var spread_angle = total_angle * offset / count
		var final_angle = base_angle + spread_angle

		var direction = Vector2.RIGHT.rotated(final_angle)

		var fireball = fireball_scene_md.instantiate()
		fireball.speed = _speed
		set_bullet_position(fireball)
		fireball.set_velocity(direction.normalized() * _speed)
		get_parent().add_child(fireball)

# endregion

func advance_to_next_path_point():
	match current_phase:
		BossPhase.PHASE0:
			speed = 300
			current_path_index = 0
		BossPhase.PHASE1:
			await get_tree().create_timer(1.0).timeout
			current_path_index += 1
			if current_path_index >= phase1_path.size():
				current_path_index = 0
			current_action = phase1_path[current_path_index]
			reached_position = false
		BossPhase.PHASE2:
			current_path_index += 1
			if current_path_index >= phase2_path.size():
				current_path_index = 0
			current_action = phase2_path[current_path_index]
			reached_position = false

func start_phase(phase):
	paused = true
	reached_position = false
	current_phase = phase
	current_path_index = 0
	
	match phase:
		BossPhase.PHASE0:
			animated_sprite_2d.play("idle")
			current_action = phase0_path[0]
		BossPhase.PHASE1:
			animated_sprite_2d.play("idle")
			current_action = phase1_path[0]
		BossPhase.PHASE2:
			await get_tree().create_timer(3.0).timeout
			speed = 1000
			animated_sprite_2d.play("idle")
			current_action = phase2_path[0]
		BossPhase.PHASE3:
			animated_sprite_2d.play("shoot_normal")

	paused = false

# Shoot directly at the player
func shoot_toward_player():
	if get_even_counter() == 0:
		for i in 3:
			var fireball = fireball_scene_md.instantiate()
			get_parent().add_child(fireball)
			set_bullet_position(fireball)
			fireball.speed = 400
			var dir = (player.global_position - fireball.position).normalized()
			fireball.set_velocity(dir * 200)
			await get_tree().create_timer(0.3).timeout
	else:
		for i in range(4):
			var angle = -15 + i * 10
			var dir2 = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball2 = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball2)
			set_bullet_position(fireball2)
			fireball2.set_velocity(dir2 * 200)

# Shoot multiple bullets in a spread pattern
func shoot_spread(count: int, angle_step: float, _speed: float):
	if !_speed:
		_speed = 300
	if get_even_counter() == 0:
		for i in range(count):
			var angle = - angle_step * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.speed = _speed
			fireball.set_velocity(dir * 200)
	else:
		for i in range(count):
			var angle = -2.0 * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.speed = _speed
			fireball.set_velocity(dir * 200)

# Rain bullets vertically
func shoot_rain(count, angle_step: float):
	if get_even_counter() == 0:
		var fireball0 = fireball_scene_sm.instantiate()
		get_parent().add_child(fireball0)
		fireball0.position = position
		fireball0.speed = 400
		var dir0 = (player.global_position - fireball0.position).normalized()
		fireball0.set_velocity(dir0 * 200)

		for i in range(count):
			var angle = - angle_step * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.speed = 100
			fireball.set_velocity(dir * 200)
	else:
		for i in range(count):
			var angle = -2 * (count - 1) / 2 + i * angle_step
			var dir = Vector2.LEFT.rotated(deg_to_rad(angle))
			var fireball = fireball_scene_sm.instantiate()
			get_parent().add_child(fireball)
			fireball.position = position
			fireball.speed = 100
			fireball.set_velocity(dir * 200)

func set_bullet_position(bullet: Area2D, _direction = 0):
	if _direction == 0:
		bullet.position = position + Vector2(-130, -20)
	elif _direction == 1:
		bullet.position = position + Vector2(130, -20)

func take_damage(amount: int):
	health -= amount
	hp_bar.value = health
	if current_phase == BossPhase.PHASE1 and health <= 700:
		call_deferred("start_phase", BossPhase.PHASE2)
	elif current_phase == BossPhase.PHASE2 and health <= 400:
		call_deferred("start_phase", BossPhase.PHASE3)


	if health <= 0:
		die()

func die():
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
