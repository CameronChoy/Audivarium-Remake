extends Enemy
var d = preload("res://Objects/Enemies/EnemyDestroyParticles_01.tscn")
export(float) var rotation_lerp = 0.05
func _init():
	destroy_effect = d

func _process(_delta):
	
	if !PlayerGlobals.current_player: return
	
	rotation = _lerp_angle(rotation,global_position.angle_to_point(PlayerGlobals.current_player.global_position),rotation_lerp)
	
	var direction = -Vector2(cos(rotation), sin(rotation))
	
	global_position += direction * acceleration * _delta
	
