extends Node2D

@export var power_increase = 1  # Amount by which the power level increases when picked
@export var move_speed = 50  # Speed at which the item moves to the left
@export var oscillation_amplitude = 20
@export var oscillation_speed = 2

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $item_area/CollisionShape2D
@onready var pick_audio: AudioStreamPlayer2D = $pick_audio

var original_y_position: float
var picked = false

func _ready():
	visible = true
	original_y_position = position.y

func _process(delta: float) -> void:
	if picked:
		return

	position.x -= move_speed * delta
	position.y = original_y_position + sin(Time.get_ticks_usec() / 1000000.0 * oscillation_speed) * oscillation_amplitude
	if position.x + sprite.texture.get_width() < 0:
		queue_free()

func _on_item_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and !picked:
		picked = true
		visible = false
		pick_audio.play()
		area.increase_speed()
		await pick_audio.finished
		queue_free()
