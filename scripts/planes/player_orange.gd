extends Area2D

@export var speed = 200  # Adjust speed as needed
@onready var shot_audio: AudioStreamPlayer2D = $shot
const BULLET_SCENE = preload("res://scene/planes/bullet.tscn")  # Preload bullet scene

# Player's spawn position (can be adjusted to suit your needs)
var spawn_position = Vector2(400, 300)  # Example position, adjust as needed

var power_level = 1

func _ready():
	# Set player spawn position at the start of the game
	position = spawn_position

func _physics_process(delta):
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

	# Keep the plane inside the screen bounds
	var viewport_rect = get_viewport().get_visible_rect()
	position.x = clamp(position.x, 80, viewport_rect.size.x - 80)
	position.y = clamp(position.y, 16, viewport_rect.size.y - 28)

	# Fire bullets when the accept button is pressed
	if Input.is_action_just_pressed("ui_accept"):
		fire_bullets()

func fire_bullets():
	var angles = []
	var bullet_offset = Vector2(60, 15)

	if power_level == 1:
		angles = [0]

	elif power_level == 2:
		var bullet1 = build_bullet()
		bullet1.position = position + bullet_offset + Vector2(0, -4)
		var bullet2 = build_bullet()
		bullet2.position = position + bullet_offset + Vector2(0, 4)
		
	elif power_level == 3:
		angles = [-10, 0, 10]

	elif power_level == 4:
		var bullet1 = build_bullet()
		bullet1.position = position + bullet_offset + Vector2(0, -4)
		var bullet2 = build_bullet()
		bullet2.position = position + bullet_offset + Vector2(0, 4)
		angles = [-10, 10]

	for angle in angles:
		var bullet = build_bullet()
		bullet.position = position + bullet_offset
		var direction = Vector2(1, 0).rotated(deg_to_rad(angle))
		bullet.direction = direction.normalized()
	# shot_audio.play()

func build_bullet():
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	return bullet

func increase_power(power_increase: int):
	power_level += power_increase
	# Cap the power level at 4
	if power_level > 4:
		power_level = 4
		GlobalManager.add_score(500)
		
func die():
	pass
