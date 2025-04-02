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
	position.x = clamp(position.x, 0, viewport_rect.size.x)
	position.y = clamp(position.y, 0, viewport_rect.size.y)

	# Fire bullets when the accept button is pressed
	if Input.is_action_just_pressed("ui_accept"):
		fire_bullets()

func fire_bullets():
	# Define bullet offsets and angles based on power level
	var angles = []
	var bullet_offset = Vector2(60, 18)  # Adjust based on your plane's size

	# Adjust the number and direction of bullets based on power level
	if power_level == 1:
		angles = [0]

	elif power_level == 2:
		# Power level 2: Shoot 3 bullets, one 10 degrees up, one straight, one 10 degrees down
		angles = [-10, 0, 10]  # Three different angles

	elif power_level == 3:
		# Power level 3: Shoot 5 bullets spread
		angles = [-20, -10, 0, 10, 20]  # Spread bullets across a range of angles

	# Create bullets with the respective angles and positions
	for angle in angles:
		var bullet = BULLET_SCENE.instantiate()
		get_parent().add_child(bullet)

		# Offset bullet to the right-bottom of the plane
		bullet.position = position + bullet_offset

		# Set the direction of the bullet based on the angle
		var direction = Vector2(1, 0).rotated(deg_to_rad(angle))  # Rotate the direction vector by the angle
		bullet.direction = direction.normalized()  # Apply direction to the bullet's movement

	# Optionally, play shot sound (you can uncomment this if you want sound)
	# shot_audio.play()

func increase_power(power_increase: int):
	power_level += power_increase
	# Cap the power level at 4
	if power_level > 4:
		power_level = 4
