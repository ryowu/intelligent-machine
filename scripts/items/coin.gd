extends Area2D

@export var move_speed = 50
@export var oscillation_amplitude = 20
@export var oscillation_speed = 2

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pick_audio: AudioStreamPlayer2D = $pick_audio
@onready var sprite: Sprite2D = $Sprite  # Reference to Sprite2D node (replace with correct node if needed)

var original_y_position: float
var picked = false

func _ready():
	visible = true
	original_y_position = position.y

func _process(delta: float) -> void:
	if picked:
		return

	# Move the item to the left
	position.x -= move_speed * delta
	
	# Add oscillation effect to the vertical movement
	# position.y = original_y_position + sin(Time.get_ticks_usec() / 1000000.0 * oscillation_speed) * oscillation_amplitude

	# Free the item when it is no longer visible (off-screen)
	if position.x + 5 < 0:
		queue_free()

# Connect this function to the signal
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and !picked:
		picked = true  # Mark the item as picked so it doesn't trigger again
		visible = false
		pick_audio.play()

		# Add score and wait for the sound to finish before freeing the object
		GlobalManager.add_score(10)
		await pick_audio.finished
		queue_free()
