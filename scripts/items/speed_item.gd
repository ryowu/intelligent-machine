extends "res://scripts/items/base_pickup_item.gd"

func do_pickup(area: Area2D):
	lbl_float.text = "SPEED UP"
	if area.has_method("increase_speed"):
		area.increase_speed()
