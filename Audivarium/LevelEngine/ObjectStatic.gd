extends Area2D
class_name Static

var bullet_solid = false
var destructable = false
var tracks
var first_track_time
var final_track_time

func step(_time : float):
	for track in tracks:
		
		track.track_step(_time, self)
		

func _update_scale_x(new : float):
	scale.x = new

func _update_scale_y(new : float):
	scale.y = new

func _update_scale(new : Vector2):
	scale = new

func _update_position_x(new : float):
	position.x = new

func _update_position_y(new : float):
	position.y = new

func _update_position(new : Vector2):
	position = new

func _bezier_update_position_x(p, t):
	position.x = bezier(p[0], p[1], p[2], p[3], t).y

func _bezier_update_position_y(p, t):
	position.y = bezier(p[0], p[1], p[2], p[3], t).y

func _bezier_update_scale_x(p, t):
	scale.x = bezier(p[0], p[1], p[2], p[3], t).y

func _bezier_update_scale_y(p, t):
	scale.y = bezier(p[0], p[1], p[2], p[3], t).y

func _bezier_update_rotation(p, t):
	rotation = bezier(p[0], p[1], p[2], p[3], t).y

func _bezier_update_rotation_deg(p, t):
	rotation_degrees = bezier(p[0], p[1], p[2], p[3], t).y

func _update_rotation(new : float):
	rotation = new

func _update_rotation_degrees(new : float):
	rotation_degrees = new

func _set_color(new : Color):
	modulate = new

func _set_z_index(new : int):
	z_index = new

func set_bullet_solid(new : bool):
	bullet_solid = new

func is_bullet_solid():
	return bullet_solid

func set_destructable(new : bool):
	destructable = new

func is_destructable():
	return destructable

func get_first_track_time():
	return first_track_time

func get_final_track_time():
	return final_track_time

func bezier(p1, p2, p3, p4, t : float):
	
	var t_inverse = 1.0-t
	var ti_s = t_inverse * t_inverse
	var t_s = t * t
	
	return (ti_s * t_inverse * p1) + \
			(3.0 * ti_s * t * p2) + \
			(3.0 * t_inverse * t_s * p3) + \
			(t_s * t * p4)
	
