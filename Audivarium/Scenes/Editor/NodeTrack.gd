extends MarginContainer
onready var KeyframeView = $VSplitContainer/KeyframePanel/Control
onready var TrackLabel = $VSplitContainer/LabelPanel/Label
var Keyframe = preload("res://Scenes/Editor/Keyframe.tscn")
var manager
enum StepTypes {LINEAR, NEAREST, BEZIER}
var step_type = StepTypes.LINEAR
var keys = []
signal track_selected


func set_name(new : String):
	name = new
	TrackLabel.text = new


func get_value_in_time(_time):
	var first_key
	var end_key
	if keys.size() < 1:
		return
	
	for k in keys:
		if k.time == _time:
			return k.values
		if k.time < _time and first_key == null:
			first_key = k
			continue
		if k.time > _time:
			end_key = k
			break
	
	match step_type:
		StepTypes.LINEAR:
			var t = ((_time - first_key.time) / (end_key.time - first_key.time))
			return (end_key.values - first_key.values) * t
		StepTypes.NEAREST:
			var first_closer = _time - first_key.time < _time - end_key.time
			return (first_key.values * int(first_closer)) + (end_key.values * int(!first_closer))
		StepTypes.BEZIER:
			var t = ((_time - first_key.time) / (end_key.time - first_key.time))
			var p1 = first_key.values
			var p2 = end_key.values
			return bezier(p1[0],p1[1],p2[0],p2[1],t)
			
		
	


func add_keyframe(values, time):
	var new_key = Keyframe.instance()
	new_key.set_values(values,time)
	var _err = new_key.connect("keyframe_selected",manager,"signal_track_focused")
	keys.append(new_key)


func delete_keyframe(key):
	keys.erase(key)


func set_steptype(new):
	step_type = new


func bezier(p1, p2, p3, p4, t : float):
	
	var t_inverse = 1.0-t
	var ti_s = t_inverse * t_inverse
	var t_s = t * t
	
	return (ti_s * t_inverse * p1) + \
			(3.0 * ti_s * t * p2) + \
			(3.0 * t_inverse * t_s * p3) + \
			(t_s * t * p4)
	


func _on_PositionX_focus_entered():
	emit_signal("track_selected",self)


func set_active(new : bool):
	visible = new
	
