extends Node2D

var speed = 200
var bounce_count = 0
var max_bounces = 7
var post_bounce_distance = 300
var final_drift_speed = 60
var edge_margin = 32

var velocity = Vector2.ZERO
var traveled_after_bounce = 0.0
var state = "bouncing"  # Can be "bouncing", "post_bounce", or "final_drift"
var picked = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $item_area/CollisionShape2D
@onready var pick_audio: AudioStreamPlayer2D = $pick_audio
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lbl_float: Label = $lbl_float

func _ready():
	visible = true
	state = "bouncing"
	bounce_count = 0
	traveled_after_bounce = 0.0

	# Randomly choose top-left or bottom-left direction
	var angle_deg = randf_range(40, 45)
	var direction_sign = -1 if (randi() % 2 == 0) else 1  # -1 for up, +1 for down
	var angle_rad = deg_to_rad(angle_deg)
	velocity = Vector2(-cos(angle_rad), direction_sign * sin(angle_rad)) * speed

func _process(delta):
	if picked:
		return

	match state:
		"bouncing":
			move_and_bounce(delta)
		"post_bounce":
			move_post_bounce(delta)
		"final_drift":
			move_final_drift(delta)

	if position.x + sprite.texture.get_width() < 0:
		queue_free()

func move_and_bounce(delta):
	position += velocity * delta
	var screen_size = get_viewport_rect().size

	var bounced = false

	if position.x <= edge_margin or position.x >= screen_size.x - edge_margin:
		velocity.x *= -1
		bounced = true

	if position.y <= edge_margin or position.y >= screen_size.y - edge_margin:
		velocity.y *= -1
		bounced = true

	if bounced:
		bounce_count += 1

		var tweak_angle = deg_to_rad(randf_range(5, 10)) * (1 if randi() % 2 == 0 else -1)
		velocity = velocity.rotated(tweak_angle).normalized() * speed

		if bounce_count >= max_bounces:
			state = "post_bounce"

func move_post_bounce(delta):
	var move = velocity * delta
	position += move
	traveled_after_bounce += move.length()

	if traveled_after_bounce >= post_bounce_distance:
		state = "final_drift"

func move_final_drift(delta):
	position.x -= final_drift_speed * delta

func _on_item_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and !picked:
		picked = true
		sprite.visible = false
		do_pickup(area)
		pick_audio.play()
		animation_player.play("float")
		await animation_player.animation_finished
		queue_free()

func do_pickup(_area: Area2D):
	pass
