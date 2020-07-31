extends Node2D

func set_active():
	for c in get_children():
		c.AI_active = true
