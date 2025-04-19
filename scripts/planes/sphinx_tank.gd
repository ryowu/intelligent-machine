extends "res://scripts/planes/base_shootable_enemy.gd"

var player: Area2D
var target_position := Vector2(800, 0)
var moving_to_target := true

func _ready():
	super._ready()

	hp = 5
	speed = 30 # Initial speed toward target_x
	score = 150
	coin_count = 1
	fireball_timer.start()

	# Set the target's Y to match current Y to keep horizontal movement
	target_position.y = global_position.y

func _process(delta):
	if moving_to_target:
		var direction = (target_position - global_position).normalized()
		var move_step = direction * speed * delta
		global_position += move_step

		var distance = (target_position - global_position).length()
		if distance < speed * delta:
			global_position = target_position
			speed = 100
			moving_to_target = false
			fireball_timer.stop()
	else:
		position.x -= speed * delta

func shoot_fireball():
	player = get_parent().get_node(GlobalConfig.PLAYER_NODE_NAME)
	if is_instance_valid(player):
		var fireball = fireball_scene.instantiate()
		fireball.position = position
		fireball.speed = 200
		get_parent().add_child(fireball)

		var dir = (player.global_position - fireball.position).normalized()
		fireball.set_velocity(dir * 200)
