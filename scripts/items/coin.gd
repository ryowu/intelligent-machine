extends Area2D

@export var move_speed = 50
@export var fly_speed = 350
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pick_audio: AudioStreamPlayer2D = $pick_audio
var player_ref: Area2D = null
var started_fly_to_player = false
var picked = false

func _ready():
	visible = true

func _process(delta: float) -> void:
	if picked:
		return

	if started_fly_to_player and is_instance_valid(player_ref):
		position = position.move_toward(player_ref.global_position, fly_speed * delta)
	else:
		position.x -= move_speed * delta

	if position.x + 5 < 0:
		player_ref = null
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and !picked:
		started_fly_to_player = false
		player_ref = null
		picked = true
		visible = false
		pick_audio.play()

		GlobalManager.add_score(10)
		await pick_audio.finished
		queue_free()
		
func fly_to_player(player: Area2D):
	started_fly_to_player = true
	player_ref = player

	
