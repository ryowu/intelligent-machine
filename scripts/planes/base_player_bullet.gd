extends Area2D

# Bullet speed
var speed = GlobalConfig.BASIC_PLAYER_BULLET_SPEED
# Bullet direction
var direction = Vector2.RIGHT
# Bullet damage
var damage = GlobalConfig.BASIC_PLAYER_BULLET_DAMAGE

@onready var sprite: Sprite2D = $Bullet

func _ready():
	# The player bullet is on the top of all stuff
	set_as_top_level(true)

func _physics_process(delta):
	_do_move(delta)
	# Remove bullet when move out of the view rect
	var viewport_size = get_viewport().get_visible_rect().size
	if position.x > viewport_size.x or position.y > viewport_size.y or position.x < 0 or position.y < 0:
		queue_free()

func _do_move(delta):
	# Move bullet to right
	position += direction.normalized() * speed * delta
