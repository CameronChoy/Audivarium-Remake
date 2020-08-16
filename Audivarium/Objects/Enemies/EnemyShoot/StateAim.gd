extends Node
onready var parent = get_parent()
var current_aim_time = 0

func update(_delta):
	parent.laser_aim()
	
	current_aim_time += _delta
	if current_aim_time >= parent.aim_time:
		parent.enter_fire()
		return parent.FireState
	
	return self
