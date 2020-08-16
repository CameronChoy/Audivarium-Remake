extends Node
onready var parent = get_parent()

func update(_delta):
	
	if parent.global_position.x < 1920 and parent.global_position.x > 0:
		if parent.global_position.y < 1080 and parent.global_position.y > 0:
			_move()
			return self
	
	if parent.global_position.distance_squared_to(PlayerGlobals.current_player.global_position) <= parent.max_distance * parent.max_distance:
		parent.enter_aim()
		return parent.AimState
	
	_move()
	return self
	


func _move():
	parent.rotate_to_player()
	parent.move_to_player()
