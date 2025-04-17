extends Area2D

var speed = 220
var hp = 2
var score = 100
var hit_effect_delta = Vector2(30, 0)
var coin_count = 0

@onready var explosion: AnimatedSprite2D = $explosion
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var enemy_body: Sprite2D = $enemy_body
@onready var explode_audio: AudioStreamPlayer2D = $audio_explode
@onready var hit_animation: AnimatedSprite2D = $hit_animation

var coin_scene: PackedScene = preload("res://scene/items/coin.tscn") # Preload the coin scene
var dying = false
var hit_playing = false
var field_entered = false

func _physics_process(delta):
	if dying:
		return
	do_move(delta)

	var screen_rect = get_viewport().get_visible_rect()
	var in_screen = screen_rect.has_point(global_position + Vector2(30, 0))
	if in_screen:
		field_entered = true
	if field_entered and not in_screen:
		queue_free()

func do_move(delta) -> void:
	position.x -= speed * delta

func _on_area_entered(area):
	if !dying and area.is_in_group("player_bullet"):
		do_hurt(area)

func play_explosion():
	explosion.visible = true
	explode_audio.play()
	explosion.play("explode")
	call_deferred("_disable_enemy")
	call_deferred("spawn_items")
	await explosion.animation_finished
	queue_free()

func _disable_enemy():
	collision.disabled = true # Disable the collision shape
	enemy_body.visible = false # Make the enemy invisible

func spawn_items():
	for i in range(coin_count):
		var coin_instance = coin_scene.instantiate()
		coin_instance.position = position
		get_parent().add_child(coin_instance)

func drop_widget(widget: Resource):
	if widget:
		var speed_item = widget.instantiate()
		speed_item.position = position
		get_parent().add_child(speed_item)

func do_hurt(area: Area2D, keep_original = false):
	hp -= area.damage
	if !keep_original:
		area.queue_free()
	if hp <= 0:
		dying = true
		GlobalManager.add_score(score)
		play_explosion()
	else:
		if !hit_playing:
			hit_playing = true
			hit_animation.position = to_local(area.global_position) + hit_effect_delta
			hit_animation.visible = true
			hit_animation.play("hit")
			await hit_animation.animation_finished
			hit_animation.visible = false
			hit_playing = false
