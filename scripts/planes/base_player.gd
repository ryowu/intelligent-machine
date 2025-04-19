extends Area2D

const BASIC_SPEED = 200
const SPEED_INCREMENT = 50
const FIRE_COOLDOWN = 0.15
const MISSILE_COOLDOWN = 1.5
const FLY_IN_SPEED = 500

@onready var shot_audio: AudioStreamPlayer2D = $shot
@onready var skill_audio: AudioStreamPlayer2D = $skill_audio
@onready var player_die: AudioStreamPlayer2D = $player_die
@onready var explode_audio: AudioStreamPlayer2D = $explode_audio
@onready var explorsion: AnimatedSprite2D = $explorsion
@onready var player_body_sprite: Sprite2D = $player_body_sprite

var suspending = false
var control_enabled: bool = false
var immune = true
var even_bullet_counter = true
var spawn_position = Vector2(200, 300)
var speed = BASIC_SPEED

var power_level = 1
var speed_level = 1
var side_weapon_level = 0
var skill_ready = true
var time_since_last_fire = 0.0
var time_since_last_missile = 0.0
var dying = false

signal on_power_change(new_power: int)
signal on_side_power_change(new_side_power: int)
signal on_speed_change(new_speed: int)
signal on_player_die(new_life: int)

func _ready():
	GlobalManager.on_skill_ready.connect(_on_skill_ready)

func _physics_process(delta):
	if not control_enabled:
		position = position.move_toward(spawn_position, FLY_IN_SPEED * delta)
		if position.distance_to(spawn_position) < 2:
			position = spawn_position
			control_enabled = true
			await get_tree().create_timer(3).timeout
			player_body_sprite.modulate.a = 1.0
			immune = false
		return

	if suspending or dying:
		return

	time_since_last_fire += delta
	time_since_last_missile += delta

	var velocity = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1

	velocity = velocity.normalized() * speed
	position += velocity * delta

	var viewport_rect = get_viewport().get_visible_rect()
	position.x = clamp(position.x, 80, viewport_rect.size.x - 80)
	position.y = clamp(position.y, 16, viewport_rect.size.y - 28)

	if Input.is_action_pressed("ui_accept") and time_since_last_fire >= FIRE_COOLDOWN:
		fire_bullets()
		time_since_last_fire = 0.0

	if side_weapon_level > 0 and time_since_last_missile >= MISSILE_COOLDOWN:
		if Input.is_action_pressed("ui_accept"):
			fire_side_weapon()
			time_since_last_missile = 0.0

	if Input.is_action_just_pressed("ui_cancel") and skill_ready:
		GlobalManager.use_skill()
		skill_audio.play()
		launch_skill()

func fire_bullets():
	pass

func fire_side_weapon():
	pass

func launch_skill():
	pass

func increase_power(power_increase: int):
	power_level += power_increase
	# Cap the power level at 4
	if power_level > 4:
		power_level = 4
		GlobalManager.add_score(500)

	on_power_change.emit(power_level)

func increase_side_power(side_power_increase: int):
	side_weapon_level += side_power_increase
	# Cap the power level at 4
	if side_weapon_level > 2:
		side_weapon_level = 2
		GlobalManager.add_score(500)

	on_side_power_change.emit(side_weapon_level)

func increase_speed():
	speed_level += 1
	# Cap the speed level at 4
	if speed_level > 4:
		speed_level = 4
		GlobalManager.add_score(500)
	speed = BASIC_SPEED + (speed_level - 1) * SPEED_INCREMENT
	on_speed_change.emit(speed_level)

func die():
	dying = true
	player_body_sprite.visible = false
	explode_audio.play()
	player_die.play()
	explorsion.visible = true
	explorsion.play("explode_md")
	await explorsion.animation_finished
	await player_die.finished
	GlobalManager.player_life -= 1
	on_player_die.emit(GlobalManager.player_life)

func _on_gold_picker_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin") and area.has_method("fly_to_player"):
		area.fly_to_player(self)

func _on_skill_ready(is_ready):
	skill_ready = is_ready

func can_hurt() -> bool:
	return !immune and !dying
