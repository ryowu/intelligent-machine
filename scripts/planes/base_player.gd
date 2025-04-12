extends Area2D

const BASIC_SPEED = 200
const SPEED_INCREMENT = 50
const FIRE_COOLDOWN = 0.15
const MISSILE_COOLDOWN = 1.5

@export var speed = BASIC_SPEED
@onready var shot_audio: AudioStreamPlayer2D = $shot
@onready var skill_audio: AudioStreamPlayer2D = $skill_audio

var suspending = false
var even_bullet_counter = true
var spawn_position = Vector2(400, 300)
var power_level = 1
var speed_level = 1
var side_weapon_level = 0
var skill_ready = true
var time_since_last_fire = 0.0
var time_since_last_missile = 0.0

signal on_power_change(new_power: int)
signal on_side_power_change(new_side_power: int)
signal on_speed_change(new_speed: int)

func _ready():
	position = spawn_position
	GlobalManager.on_skill_ready.connect(_on_skill_ready)

func _physics_process(delta):
	if suspending:
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
	pass

func _on_gold_picker_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin") and area.has_method("fly_to_player"):
		area.fly_to_player(self)

func _on_skill_ready(is_ready):
	skill_ready = is_ready
