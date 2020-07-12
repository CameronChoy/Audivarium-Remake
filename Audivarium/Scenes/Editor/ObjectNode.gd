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
enum Tracks {PARENT,COLOR,POSITION,SCALE,Z_INDEX,BULLET_SOLID,DESTRUCTABLE}
var spawn_time
var despawn_time

var object

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


func focus():
	Properties.show()
	emit_signal("object_focused",self)


func exit_focus():
	Properties.hide()


func Header_focus():
	emit_signal("object_focused",self)
	position_Properties()
	Properties.visible = !Properties.visible
	if !is_processing():
		drag()
	Header.release_focus()


func drag():
	displacement = get_global_mouse_position() - rect_global_position
	original_position = get_global_mouse_position()
	set_process(true)
	
	


func drop():
	set_process(false)
	
	dragging = false
	
	rect_global_position.x = clamp(rect_global_position.x,
	parent.rect_global_position.x,
	parent.rect_global_position.x + parent.rect_size.x - rect_size.x)
	
	rect_global_position.y = clamp(rect_global_position.y,
	parent.rect_global_position.y,
	parent.rect_global_position.y + parent.rect_size.y)
	
	current_position = rect_global_position
	position_Properties()
	calculate_spawn_despawn_times()
	reposition_keyframes()
	
	emit_signal("object_repositioned")


func position_Properties():
	Properties.rect_global_position = rect_global_position
	Properties.rect_global_position.y += 56


func _process(_delta):
	
	if dragging:
		rect_global_position = get_global_mouse_position() - displacement
		
	elif (get_global_mouse_position() - original_position).length_squared() > deadzone * deadzone:
		dragging = true
		Properties.hide()
		
	


func _input(event):
	if is_processing():
		if event.is_action_released("lmb"):
			if dragging:
				Properties.show()
			drop()
		
	


func delete_node():
	pass


func calculate_spawn_despawn_times():
	pass


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
