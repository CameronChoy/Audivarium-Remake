extends Node
class_name ObjectTrack

var track_type = -1
var enabled = true
var step_type = 0
var points = []
var times = []

enum TrackTypes {
	POSITION,
	SCALE,
	ROTATION,
	ROTATION_DEG,
	COLOR,
	BEZIER_POSITION_X,
	BEZIER_POSITION_Y,
	BEZIER_SCALE_X,
	BEZIER_SCALE_Y,
	BEZIER_ROTATION,
	BEZIER_ROTATION_DEG,
	Z_INDEX,
	BULLET_SOLID,
	DESTRUCTABLE,
	BEHAVIOR,
}

enum StepTypes {
	LINEAR,
	BEZIER,
	NEAREST,
}

func track_step(_time : float, _object : Static):
	if !is_enabled() or points.empty(): return
	
	#TODO

func get_track_type():
	return track_type

func get_first_time():
	return times[0]

func set_points(new : Array):
	points = new

func set_times(new : Array):
	times = new

func set_enabled(new : bool):
	enabled = new

func is_enabled():
	return enabled


