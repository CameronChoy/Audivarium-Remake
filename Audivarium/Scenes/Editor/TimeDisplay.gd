extends Control

onready var TimeSelector = $TimeSelector

var manager
var timeline
var font = preload("res://Fonts/typerighter/typewriter.tres")
var time_differences = [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10]
signal selected_level_time_changed

func _ready():
	set_process(false)

func _draw():
	if !manager: return
	
	
#	var start_pos = abs(rect_global_position.x - timeline.rect_global_position.x)
#	var start_time = start_pos / manager.time_scale
	#var zoom_scale = manager.zoom_level / manager.LevelTime
	
	rect_size.x = timeline.rect_size.x
	reposition()
	
	var zoom_scale = manager.LevelTime/manager.zoom_level
	var time_diff = 1
	for i in time_differences:
		
		if  zoom_scale > i*10:
			time_diff = i
			
		
	
	
#	var temp_time = floor(start_time)
#	while(temp_time < start_time):
#		temp_time += time_diff
#
#	var offset = (temp_time - start_time) * manager.time_scale
	
	var pos_diff = time_diff * manager.time_scale
	var string_y = rect_size.y / 1.5
	var iterations = floor(rect_size.x / pos_diff)
	
	for iter in range(iterations):#range(0,rect_size.x, pos_diff):
		var pos = (pos_diff * iter)
		
		draw_line(Vector2(pos,0),Vector2(pos,rect_size.y),Color.white)
		draw_string(font,Vector2(pos+5, string_y),str(time_diff * iter))
	
	TimeSelector.rect_position.x = manager.CurrentLevelTime * manager.time_scale


func reposition():
	rect_global_position.x = timeline.rect_global_position.x


func _on_TimeSelectorFocus_button_down():
	set_process(true)


func _on_TimeSelectorFocus_button_up():
	set_process(false)

func _process(_delta):
	TimeSelector.rect_position.x = clamp(get_local_mouse_position().x, 0,rect_size.x)
	manager.CurrentLevelTime = TimeSelector.rect_position.x / manager.time_scale
	emit_signal("selected_level_time_changed")
	
