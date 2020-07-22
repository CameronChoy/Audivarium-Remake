extends Button

var values = []
var time = -1
var dragging = false
var displacement
var original_position
var parent
signal keyframe_selected


func set_values(_values, _time):
	values = _values
	time = _time
	


func _on_Keyframe_pressed():
	emit_signal("keyframe_selected",self)


func _on_Keyframe_button_down():
	displacement = get_local_mouse_position().x - rect_position.x
	original_position = get_global_mouse_position()
	set_process(true)


func _on_Keyframe_button_up():
	pass

func _process(delta):
	if dragging:
		rect_position.x = get_local_mouse_position().x - displacement
		
	elif (get_global_mouse_position() - original_position).length_squared() > parent.manager.deadzone * parent.manager.deadzone:
		dragging = true
	

