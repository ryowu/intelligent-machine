extends Node2D

var move_speed = 50  # Speed at which the item moves to the left
var oscillation_amplitude = 20  # How far up and down the item will move
var oscillation_speed = 2  # How fast the item moves up and down

@onready var sprite: Sprite2D = $Sprite2D  # Assuming the item has a Sprite2D node
@onready var collision: CollisionShape2D = $item_area/CollisionShape2D
@onready var pick_audio: AudioStreamPlayer2D = $pick_audio
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var lbl_float: Label = $lbl_float

var original_y_position: float
var picked = false

func _ready():
	visible = true  # Make sure the item is initially visible
	move_speed = 50
	oscillation_amplitude = 20
	oscillation_speed = 2
	original_y_position = position.y  # Store the original Y position for oscillation

func _process(delta: float) -> void:
	if picked:
		return
	# Move the item to the left
	position.x -= move_speed * delta
	
	# Oscillate the item up and down using a sine wave
	position.y = original_y_position + sin(Time.get_ticks_usec() / 1000000.0 * oscillation_speed) * oscillation_amplitude

	# Check if the item is outside of the viewport
	if position.x + sprite.texture.get_width() < 0:
		queue_free()

func _on_item_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and !picked:
		picked = true
		sprite.visible = false
		do_pickup(area)
		pick_audio.play()
		animation_player.play("float")
		await pick_audio.finished
		await animation_player.animation_finished
		queue_free()

func do_pickup(_area: Area2D):
	pass
