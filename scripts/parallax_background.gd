extends ParallaxBackground

@export var base_speed = 100  # Base speed of background scrolling
@export var speed_multiplier = 1.0  # Adjust this for overall speed changes

func _process(delta):
	scroll_offset.x -= base_speed * speed_multiplier * delta  # Move the background left
