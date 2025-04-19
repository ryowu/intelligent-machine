extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var elec_sound: AudioStreamPlayer2D = $elec_sound
@onready var check_timer: Timer = Timer.new()

const EXPLODE_SCALE = 1.3
const EXPLODE_COLLISION_SCALE = 4.2

var damage = 6
var speed = 200
var move_distance = 300
var moved = 0
var is_moving = true
var exploded = false
var timer := 0.0

func _ready():
	animated_sprite_2d.play("move")
	
	check_timer.wait_time = 0.2
	check_timer.one_shot = false
	check_timer.timeout.connect(_on_check_collision)
	add_child(check_timer)
	check_timer.start()

func _process(delta):
	if is_moving:
		var step = speed * delta
		position.x += step
		moved += step

		var view_right = get_viewport().get_visible_rect().end.x
		if moved >= move_distance or position.x >= view_right:
			_start_explode()
	elif exploded:
		timer += delta
		if timer >= 3.0:
			elec_sound.stop()
			queue_free()

func _start_explode():
	if exploded:
		return
	is_moving = false
	exploded = true
	elec_sound.play()
	collision_shape_2d.scale = Vector2(EXPLODE_COLLISION_SCALE, EXPLODE_COLLISION_SCALE)
	animated_sprite_2d.scale = Vector2(EXPLODE_SCALE, EXPLODE_SCALE)
	animated_sprite_2d.play("explode")

func _on_check_collision():
	var overlapping_areas = get_overlapping_areas()
	for area in overlapping_areas:
		if area != self:
			if area.is_in_group("enemy"):
				area.do_hurt(self, true)
			elif area.is_in_group("enemy_bullet"):
				area.queue_free()
