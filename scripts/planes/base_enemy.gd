extends Area2D

@export var speed = 220
@export var hp = 3
@export var score = 100
@onready var explosion: AnimatedSprite2D = $explosion
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var enemy_body: Sprite2D = $enemy_body
@onready var explode_audio: AudioStreamPlayer2D = $audio_explode
@export var coin_scene: PackedScene = preload("res://scene/items/coin.tscn")  # Preload the coin scene

var dying = false

func _physics_process(delta):
	if dying: return
	do_move(delta)

	if position.x < -300 or position.x < -get_viewport().size.x:
		queue_free()

func do_move(delta) -> void:
	position.x -= speed * delta

func _on_area_entered(area):
	if !dying and area.is_in_group("player_bullet"):  # Check if hit by a player bullet
		hp -= 1  # Decrease HP by 1
		area.queue_free()  # Remove bullet
		if hp <= 0:  # If HP reaches zero, play explosion
			dying = true
			GlobalManager.add_score(score)
			play_explosion()

func play_explosion():
	explosion.visible = true
	explode_audio.play()
	explosion.play("explode")  # Play the explosion animation
	# Use call_deferred to disable the collision and make the enemy invisible safely
	call_deferred("_disable_enemy")

	# Spawn 2 to 3 coins randomly around the enemy's position
	call_deferred("spawn_coins")

	# Queue the enemy for removal after the explosion animation finishes
	await explosion.animation_finished
	queue_free()  # Remove the enemy and its explosion animation

# Deferred function to disable enemy
func _disable_enemy():
	collision.disabled = true  # Disable the collision shape
	enemy_body.visible = false  # Make the enemy invisible

# Function to spawn 2 to 3 coins around the enemy's position
func spawn_coins():
	var coin_count = randi_range(1, 2)  # Randomly choose 2 or 3 coins
	for i in range(coin_count):
		var coin_instance = coin_scene.instantiate()
		# Set a random position around the enemy (using a small offset)
		# var random_offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		coin_instance.position = position# + random_offset
		get_parent().add_child(coin_instance)  # Add coin to the scene
