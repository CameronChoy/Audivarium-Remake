extends Enemy


func _physics_process(_delta):
	if !PlayerGlobals.current_player: return
	
	rotation = (global_position.angle_to_point(PlayerGlobals.current_player.global_position))
	
	var direction = -Vector2(cos(rotation), sin(rotation))
	
	global_position += direction * acceleration * _delta
	
