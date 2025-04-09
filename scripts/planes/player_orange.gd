extends Area2D

const BASIC_SPEED = 200
const SPEED_INCREMENT = 50
const FIRE_COOLDOWN = 0.15
const MISSILE_COOLDOWN = 1.5

@export var speed = BASIC_SPEED  # Adjust speed as needed
@onready var shot_audio: AudioStreamPlayer2D = $shot
var suspending = false
var even_bullet_counter = true
const BULLET_SCENE = preload("res://scene/planes/player_bullet_green.tscn")  # Preload bullet scene
const MISSILE_SCENE = preload("res://scene/planes/missile.tscn") 
# Player's spawn position (can be adjusted to suit your needs)
var spawn_position = Vector2(400, 300)  # Example position, adjust as needed
var power_level = 1
var speed_level = 1
var side_weapon_level = 0
var time_since_last_fire = 0.0
var time_since_last_missile = 0.0

signal on_power_change(new_power: int)
signal on_side_power_change(new_side_power: int)
signal on_speed_change(new_speed: int)

func _ready():
	# Set player spawn position at the start of the game
	position = spawn_position

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
			fire_missiles()
			time_since_last_missile = 0.0

func fire_missiles():
	if side_weapon_level == 1:
		var missile1 = build_missile()
		missile1.direction_up = false
		missile1.start_position = position + Vector2(0, 15)
		var missile2 = build_missile()
		missile2.start_position = position + Vector2(0, 15)
	elif side_weapon_level == 2:
		var missile1 = build_missile()
		missile1.direction_up = false
		missile1.scale_delta = 20
		missile1.start_position = position + Vector2(0, 15)
		var missile2 = build_missile()
		missile2.direction_up = false
		missile2.start_position = position + Vector2(0, 15)
		var missile3 = build_missile()
		missile3.scale_delta = 20
		missile3.start_position = position + Vector2(0, 15)
		var missile4 = build_missile()
		missile4.start_position = position + Vector2(0, 15)


func fire_bullets():
	var angles = []
	var bullet_offset = Vector2(60, 15)
	var bullet_mode = 3

	if power_level == 1:
		if even_bullet_counter:
			bullet_mode = 3
		else:
			bullet_mode = 1
		even_bullet_counter = !even_bullet_counter
		angles = [0]
	elif power_level == 2:
		bullet_mode = 3
		var bullet1 = build_bullet(bullet_mode)
		bullet1.position = position + bullet_offset + Vector2(0, -6)
		var bullet2 = build_bullet(bullet_mode)
		bullet2.position = position + bullet_offset + Vector2(0, 6)
	elif power_level == 3:
		bullet_mode = 3
		angles = [-10, 0, 10]
	elif power_level == 4:
		var bullet1 = build_bullet(bullet_mode)
		bullet1.position = position + bullet_offset + Vector2(0, -6)
		var bullet2 = build_bullet(bullet_mode)
		bullet2.position = position + bullet_offset + Vector2(0, 6)
		angles = [-10, 10]

	for angle in angles:
		var bullet = build_bullet(bullet_mode)
		bullet.position = position + bullet_offset
		var direction = Vector2(1, 0).rotated(deg_to_rad(angle))
		bullet.direction = direction.normalized()
	# shot_audio.play()

func build_bullet(bullet_mode: int):
	var bullet = BULLET_SCENE.instantiate()
	bullet.bullet_mode = bullet_mode
	get_parent().add_child(bullet)
	return bullet

func build_missile():
	var missile = MISSILE_SCENE.instantiate()
	get_parent().add_child(missile)
	return missile

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

	
