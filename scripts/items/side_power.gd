extends "res://scripts/items/base_pickup_item.gd"

func do_pickup(area: Area2D):
	lbl_float.text = "SIDE WEAPON UP"
	if area.has_method("increase_side_power"):
		area.increase_side_power(1)
