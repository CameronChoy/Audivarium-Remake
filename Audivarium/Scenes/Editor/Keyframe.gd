extends Button

var values = []
var time = -1
var dragging = false
var displacement
var original_position = Vector2()
var track
signal keyframe_selected
signal keyframe_time_changed


func _ready():
	set_process(false)

func set_values(_values, _time):
	values = _values
	time = _time
	


func _on_Keyframe_pressed():
	emit_signal("keyframe_selected",self)


func _on_Keyframe_button_down():
	displacement = get_global_mouse_position().x - rect_global_position.x
	original_position = get_global_mouse_position()
	set_process(true)


func _on_Keyframe_button_up():
	set_process(false)
	dragging = false
	

func _process(delta):
	if dragging:
		rect_global_position.x = clamp(
		get_global_mouse_position().x - displacement,
		track.rect_global_position.x,
		track.rect_global_position.x+track.rect_size.x)
		time = rect_position.x / track.manager.time_scale
		print(time)
	elif (get_global_mouse_position() - original_position).length_squared() > track.manager.deadzone * track.manager.deadzone:
		dragging = true
	

