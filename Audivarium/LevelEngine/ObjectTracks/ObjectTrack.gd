extends Node
class_name ObjectTrack

var track_type = -1
var enabled = true
var step_type = 0
var points = []
var times = []
var x_track = true

enum TrackTypes {
	POSITION,
	SCALE,
	ROTATION, #Discarded
	ROTATION_DEG,
	COLOR,
	BEZIER_POSITION_X, #Combined with Normal Variant
	BEZIER_POSITION_Y, #Combined with Normal Variant
	BEZIER_SCALE_X, #Combined with Normal Variant
	BEZIER_SCALE_Y, #Combined with Normal Variant
	BEZIER_ROTATION, #Discarded
	BEZIER_ROTATION_DEG, #Combined with Normal Variant
	Z_INDEX,
	BULLET_SOLID, #Not implemented
	DESTRUCTABLE, #Not implemented
	BEHAVIOR, #Not implemented
}

enum StepTypes {
	LINEAR,
	BEZIER,
	NEAREST,
}

func track_step(_time : float, _object : Static):
	return
	#if !is_enabled() or points.empty(): return
	

func init_set(_enabled : bool, _step_type : int, _points : Array, _times : Array, _x_track : bool = true):
	#track_type = _track_type
	enabled = _enabled
	step_type = clamp(_step_type, 0, TrackTypes.size())
	
	points = _points
	times = _times
	x_track = _x_track
	

func convert_to_bezier():
	return

func is_empty():
	return points.empty()

func get_track_type():
	return track_type

func get_first_time():
	return times.front()

func get_final_time():
	return times.back()

func is_x_track():
	return x_track

func set_points(new : Array):
	points = new

func set_times(new : Array):
	times = new

func set_enabled(new : bool):
	enabled = new

func is_enabled():
	return enabled


