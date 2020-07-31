extends Node2D

func _ready():
	var pos = rand_range(128,384)
	for c in get_children():
		c.monitoring = false
		c.position.x = pos
		pos += rand_range(128,384)

func random():
	for c in get_children():
		c.monitoring = false
		c.position.x += rand_range(-128,128)
