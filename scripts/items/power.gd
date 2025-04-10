extends "res://scripts/items/base_pickup_item.gd"

func do_pickup(area: Area2D):
	lbl_float.text = "POWER UP"
	if area.has_method("increase_power"):
		area.increase_power(1)
