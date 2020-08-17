extends Node
onready var parent = get_parent()
var current_fire_time = 0

func update(_delta):
	parent.laser_aim(false)
	
	current_fire_time += _delta
	if current_fire_time >= parent.fire_delay_time:
		parent.shoot()
		parent.enter_reload()
		return parent.ReloadState
	
	return self
