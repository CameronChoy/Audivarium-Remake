extends Button

var values = []
var time = -1
signal keyframe_selected


func set_values(_values, _time):
	values = _values
	time = _time
	


func _on_Keyframe_pressed():
	emit_signal("keyframe_selected",self)
