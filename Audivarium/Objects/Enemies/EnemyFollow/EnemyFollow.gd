extends Enemy
var d = preload("res://Objects/Enemies/EnemyDestroyParticles_01.tscn")
export(float) var rotation_lerp = 0.05
func _init():
	destroy_effect = d

func _physics_process(_delta):
	
	if !PlayerGlobals.current_player: return
	
	rotation = _lerp_angle(rotation,global_position.angle_to_point(PlayerGlobals.current_player.global_position),rotation_lerp)
	
	var direction = -Vector2(cos(rotation), sin(rotation))
	
	global_position += direction * acceleration * _delta
	

func _lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
