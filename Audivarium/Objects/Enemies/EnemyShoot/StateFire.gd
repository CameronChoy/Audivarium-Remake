extends Node
onready var parent = get_parent()
var current_reload_time = 0

func update(_delta):
	parent.laser_aim(false)
	
	current_reload_time += _delta
	
	
	return self
