extends VBoxContainer
class_name ObjectNode

var Track_Node = preload("res://Scenes/Editor/NodeTrack.tscn")

onready var Properties = $Popup
onready var NameLabel = $NameEdit
onready var Header = $Button
onready var TrackContainer = $Popup/ScrollContainer/TrackContainer
var displacement
var original_position
var current_position
var dragging = false

const KEYFRAME_SIZE = Vector2(10,24)
onready var parent = get_parent()

signal object_focused
signal object_repositioned
signal object_name_changed

enum Tracks {POSITION,ROTATION,SCALE,COLOR,BULLET_SOLID,DESTRUCTABLE,Z_INDEX,PARENT}
var manager
var prev_name
var spawn_time = 0
var despawn_time = 1

var tracks = []
var object
var layer

var parent_track_active = false
var parent_track

var rotation_track_active = true
var rotation_track

var color_track_active = false
var color_track

var positionx_track_active = true
var positionx_track
var positiony_track_active = true
var positiony_track

var scalex_track_active = true
var scalex_track
var scaley_track_active = true
var scaley_track

var z_track_active = false
var z_track

var bullet_track_active = false
var bullet_track

var destructable_track_active = false
var destructable_track


func _ready():
	set_process(false)
	current_position = rect_global_position
	
	for x in range(Tracks.size()):
		
		match x:
			Tracks.POSITION, Tracks.SCALE:
				_add_track(x)
				_add_track(x,false)
				
			Tracks.ROTATION:
				_add_track(x)
			_:
				var t =_add_track(x,false)
				t.set_active(false)
				
			
		
	
	positionx_track.active = true
	positiony_track.active = true
	scalex_track.active = true
	scaley_track.active = true
	rotation_track.active = true
	


func set_name(new : String):
	name = new
	prev_name = new
	$NameEdit.text = new


func set_manager(new):
	manager = new
	var _err = (connect("object_focused",manager,"signal_object_focused",[self]))
	_err = (connect("object_name_changed",manager,"signal_object_name_changed",[self]))


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
	#emit_signal("object_focused")
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
	
	Properties.rect_size.x = rect_size.x
	Properties.rect_global_position = rect_global_position
	Properties.rect_global_position.y += 56
	
	reposition_keyframes()
	


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
	elif (get_global_mouse_position() - original_position).length_squared() > manager.deadzone * manager.deadzone:
		dragging = true
		Properties.hide()
		
	


func _input(event):
	if is_processing():
		if event.is_action_released("lmb"):
			
			set_process(false)
			dragging = false
			
			if dragging:
				Properties.show()
				drop()
			
		
	


func _add_track(track : int, x_track : bool = true):
	var new_track = Track_Node.instance()
	var n = ""
	
	match track:
		Tracks.BULLET_SOLID:
			n = "Bullet Solid"
			bullet_track = new_track
			new_track.value_type = NodeTrack.ValueTypes.BOOLEAN
		Tracks.COLOR:
			n = "Color"
			color_track = new_track
			new_track.value_type = NodeTrack.ValueTypes.COLOR
		Tracks.DESTRUCTABLE:
			n = "Destructable"
			destructable_track = new_track
			new_track.value_type = NodeTrack.ValueTypes.BOOLEAN
		Tracks.PARENT:
			n = "Parent"
			parent_track = new_track
			new_track.value_type = NodeTrack.ValueTypes.STRING
		Tracks.ROTATION:
			n = "Rotation"
			rotation_track = new_track
			new_track.value_type = NodeTrack.ValueTypes.FLOAT
		Tracks.POSITION:
			new_track.value_type = NodeTrack.ValueTypes.FLOAT
			if x_track:
				n = "Position X"
				positionx_track = new_track
			else:
				n = "Position Y"
				positiony_track = new_track
			
		Tracks.SCALE:
			new_track.value_type = NodeTrack.ValueTypes.FLOAT
			if x_track:
				n = "Scale  X"
				scalex_track = new_track
			else:
				n = "Scale Y"
				scaley_track = new_track
			
			
		Tracks.Z_INDEX:
			n = "Z Index"
			z_track = new_track
			new_track.value_type = NodeTrack.ValueTypes.INTEGER
		_:
			return
	
	new_track.manager = manager
	new_track.object_parent = self
	TrackContainer.add_child(new_track)
	new_track.set_name(n)
	tracks.append(new_track)
	
	return new_track
	


func toggle_track(track : int, active : bool, x_track : bool = true):
	
	match track:
		Tracks.BULLET_SOLID:
			bullet_track.visible = active
			bullet_track_active = active
			bullet_track.active = active
		Tracks.COLOR:
			color_track.visible = active
			color_track_active = active
			color_track.active = active
		Tracks.DESTRUCTABLE:
			destructable_track.visible = active
			destructable_track_active = active
			destructable_track.active = active
		Tracks.PARENT:
			parent_track.visible = active
			parent_track_active = active
			parent_track.active = active
		Tracks.Z_INDEX:
			z_track.visible = active
			z_track_active = active
			z_track.active = active
		Tracks.ROTATION:
			rotation_track.visible = active
			rotation_track_active = active
			rotation_track.active = active
		Tracks.POSITION:
			
			if x_track:
				positionx_track.visible = active
				positionx_track_active = active
				positionx_track.active = active
			else:
				positiony_track.visible = active
				positiony_track_active = active
				positiony_track.active = active
		
		Tracks.SCALE:
			
			if x_track:
				scalex_track.visible = active
				scalex_track_active = active
				scalex_track.active = active
			else:
				scaley_track.visible = active
				scaley_track_active = active
				scaley_track.active = active
			
		
		_:
			return
	

func delete_node():
	pass


func calculate_spawn_despawn_times():
	var time_scale = manager.time_scale
	spawn_time = (rect_global_position.x - manager.TimelineView.rect_global_position.x) / time_scale
	despawn_time = (rect_global_position.x + rect_size.x - manager.TimelineView.rect_global_position.x) / time_scale
	


func reposition_keyframes():
	
	for t in tracks:
		
		var time_scale = rect_size.x / (despawn_time - spawn_time)
		
		for k in t.keys:
			k.rect_position.y = -3
			k.rect_position.x = time_scale * k.time
		
	


func update_step(time):
	pass 


func get_step(time):
	pass


func has_keyframe_at_time(track, time, x_track : bool = true):
	
	var t
	match track:
		Tracks.BULLET_SOLID:
			t = bullet_track
		Tracks.COLOR:
			t = color_track
		Tracks.DESTRUCTABLE:
			t = destructable_track
		Tracks.PARENT:
			t = parent_track
		Tracks.POSITION:
			t = positionx_track if x_track else positiony_track
		Tracks.SCALE:
			t = scalex_track if x_track else scaley_track
		Tracks.Z_INDEX:
			t = z_track
		_:
			return false
	
	var local_time = time - spawn_time
	
	for x in t.keys:
		if x.time == local_time: return x
	return false


func add_keyframe(track, _time, values = [0], x_track : bool = true):
	var time = _time - spawn_time
	match track:
		Tracks.BULLET_SOLID:
			bullet_track.add_keyframe(values, time)
		Tracks.COLOR:
			color_track.add_keyframe(values, time)
		Tracks.DESTRUCTABLE:
			destructable_track.add_keyframe(values, time)
		Tracks.PARENT:
			parent_track.add_keyframe(values, time)
		Tracks.Z_INDEX:
			z_track.add_keyframe(values, time)
		Tracks.POSITION:
			if x_track:
				positionx_track.add_keyframe(values, time)
			else:
				positiony_track.add_keyframe(values, time)
		Tracks.SCALE:
			if x_track:
				scalex_track.add_keyframe(values, time)
			else:
				scaley_track.add_keyframe(values, time)
		_:
			return
	


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


func modify_keyframe(track,index):
	
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
	
