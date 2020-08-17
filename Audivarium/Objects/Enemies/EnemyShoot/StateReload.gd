extends Node
onready var parent = get_parent()
var current_reload_time = 0

func update(_delta):
	current_reload_time += _delta
	
	if current_reload_time >= parent.reload_time:
		parent.enter_follow()
		return parent.FollowState
	
	return self
	
