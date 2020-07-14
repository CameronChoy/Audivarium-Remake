extends VBoxContainer
class_name ObjectNode

onready var Properties = $Popup
onready var NameLabel = $NameEdit
onready var Header = $Button
var displacement
var original_position
var current_position
var dragging = false
var deadzone = 5
onready var parent = get_parent()
signal object_focused
signal object_repositioned
signal object_name_changed
enum Tracks {PARENT,COLOR,POSITION,SCALE,Z_INDEX,BULLET_SOLID,DESTRUCTABLE}
var manager
var prev_name
var spawn_time = 0
var despawn_time = 1

var object
var layer

var parent_points = []
var parent_times = []

var color_points = []
var color_times = []

var position_points = []
var position_times = []

var scale_points = []
var scale_times = []

var z_points = []
var z_times = []

var bullet_solid_points = []
var bullet_solid_times = []

var destructable_points = []
var destructable_times = []


func _ready():
	set_process(false)
	current_position = rect_global_position
	

func set_name(new : String):
	name = new
	prev_name = new
	$NameEdit.text = new

func set_manager(new):
	manager = new
	(connect("object_focused",manager,"signal_object_focused",[self]))
	(connect("object_name_changed",manager,"signal_object_name_changed",[self]))

func set_parent(new):
	var p = get_parent()
	if p != null:
		p.remove_child(self)
	new.add_child(self)

func focus():
	position_Properties()
	Properties.show()
	emit_signal("object_focused")


func exit_focus():
	Properties.hide()


func Header_focus():
	emit_signal("object_focused")
	#position_Properties()
	#Properties.visible = !Properties.visible
	if !is_processing():
		drag()
	

func Header_released():
	Header.release_focus()

func Header_pressed():
	emit_signal("object_focused")
	position_Properties()
	Properties.visible = !Properties.visible
	if !dragging:
		set_process(false)
	#Header.release_focus()

func drag():
	displacement = get_global_mouse_position() - rect_global_position
	original_position = get_global_mouse_position()
	set_process(true)
	



func drop():
	rect_global_position.x = clamp(rect_global_position.x,
	manager.TimelineView.rect_global_position.x,
	manager.TimelineView.rect_global_position.x + manager.TimelineView.rect_size.x - rect_size.x)
	
	
	snap_to_closest_layer()
	
	
	current_position = rect_global_position
	position_Properties()
	calculate_spawn_despawn_times()
	reposition_keyframes()
	
	emit_signal("object_repositioned")


func snap_to_closest_layer():
	var closest_dist = abs(manager.layers[0].rect_global_position.y - rect_global_position.y)
	var closest_layer = manager.layers[0]
	for l in manager.layers:
		
		var dist = abs(l.rect_global_position.y - rect_global_position.y)
		if dist < closest_dist:
			closest_dist = dist
			closest_layer = l
		
	rect_global_position.y = closest_layer.rect_global_position.y


func position_Properties():
	Properties.rect_global_position = rect_global_position
	Properties.rect_global_position.y += 56
	Properties.rect_size.x = rect_size.x
	
	#position keyframes
	


func _on_NameEdit_text_entered(new_text):
	if new_text.empty():
		NameLabel.text = prev_name
	else:
		prev_name = new_text
		emit_signal("object_name_changed",NameLabel.text)


func _on_NameEdit_focus_exited():
	NameLabel.deselect()
	if NameLabel.text.empty():
		NameLabel.text = prev_name
	else:
		prev_name = NameLabel.text
		emit_signal("object_name_changed",NameLabel.text)


func _process(_delta):
	
	if dragging:
		rect_global_position = get_global_mouse_position() - displacement
		snap_to_closest_layer()
	elif (get_global_mouse_position() - original_position).length_squared() > deadzone * deadzone:
		dragging = true
		Properties.hide()
		
	


func _input(event):
	if is_processing():
		if event.is_action_released("lmb"):
			
			if dragging:
				Properties.show()
				drop()
			
			set_process(false)
			dragging = false
			
			
		
	


func delete_node():
	pass


func calculate_spawn_despawn_times():
	var time_scale = manager.time_scale
	spawn_time = (rect_global_position.x - manager.TimelineView.rect_global_position.x) / time_scale
	despawn_time = (rect_global_position.x + rect_size.x - manager.TimelineView.rect_global_position.x) / time_scale
	


func reposition_keyframes():
	pass
	


func update_step(time):
	pass 


func add_keyframe(track, index):
	
	match track:
		Tracks.BULLET_SOLID:
			pass
		Tracks.COLOR:
			pass
		Tracks.DESTRUCTABLE:
			pass
		Tracks.PARENT:
			pass
		Tracks.POSITION:
			pass
		Tracks.SCALE:
			pass
		Tracks.Z_INDEX:
			pass
		_:
			pass
	

func remove_keyframe(track, index):
	
	match track:
		Tracks.BULLET_SOLID:
			pass
		Tracks.COLOR:
			pass
		Tracks.DESTRUCTABLE:
			pass
		Tracks.PARENT:
			pass
		Tracks.POSITION:
			pass
		Tracks.SCALE:
			pass
		Tracks.Z_INDEX:
			pass
		_:
			pass





