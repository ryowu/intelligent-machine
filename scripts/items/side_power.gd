extends "res://scripts/items/base_pickup_item.gd"

func do_pickup(area: Area2D):
	lbl_float.text = "SPEED UP"
	area.increase_side_power(1)
