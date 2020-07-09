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

func _bezier_update_position_x(p):
	position.x = bezier(p[0], p[1], p[2], p[3], p[4]).y

func _bezier_update_position_y(p):
	position.y = bezier(p[0], p[1], p[2], p[3], p[4]).y

func _bezier_update_scale_x(p):
	scale.x = bezier(p[0], p[1], p[2], p[3], p[4]).y

func _bezier_update_scale_y(p):
	scale.y = bezier(p[0], p[1], p[2], p[3], p[4]).y

func _bezier_update_rotation(p):
	rotation = bezier(p[0], p[1], p[2], p[3], p[4]).y

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

func bezier(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2, t : float):
	
	var t_inverse = 1.0-t
	var ti_s = pow(t_inverse,2)
	var t_s = pow(t,2)
	
	return (ti_s * t_inverse * p1) + \
			(3.0 * ti_s * t * p2) + \
			(3.0 * t_inverse * t_s * p3) + \
			(t_s * t * p4)
	


#		match track.get_track_type():
#
#			ObjectTrack.TrackTypes.BEZIER_POSITION_X:
#				_bezier_update_position_x(track_points)
#
#			ObjectTrack.TrackTypes.BEZIER_POSITION_Y:
#				pass
#
#			ObjectTrack.TrackTypes.BEZIER_ROTATION:
#				pass
#
#			ObjectTrack.TrackTypes.BEZIER_SCALE_X:
#				pass
#
#			ObjectTrack.TrackTypes.BEZIER_SCALE_Y:
#				pass
#
#			ObjectTrack.TrackTypes.COLOR:
#				pass
#
#			ObjectTrack.TrackTypes.DESTRUCTABLE:
#				pass
#
#			ObjectTrack.TrackTypes.POSITION:
#				pass
#
#			ObjectTrack.TrackTypes.ROTATION:
#				pass
#
#			ObjectTrack.TrackTypes.SCALE:
#				pass
#
#			ObjectTrack.TrackTypes.Z_INDEX:
#				pass
#
#			ObjectTrack.TrackTypes.BULLET_SOLID:
#				pass
#
#			_:
#				continue
#
