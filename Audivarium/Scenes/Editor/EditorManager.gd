extends Node2D

const TitleScene = "res://Scenes/MainMenu/TitleMenu/TitleMain.tscn"
var saved

var NodeObject = preload("res://Scenes/Editor/ObjectNode.tscn")
var DefaultObject = preload("res://Objects/Statics/Circle.tscn")

onready var AudioPlayer = $AudioStreamPlayer
onready var FileSelector = $Control/FileDialog

onready var Simulator = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/LevelDisplayContainer/Panel/MarginContainer/ViewportContainer/LevelSimulator
onready var SimulatorCamera = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/LevelDisplayContainer/Panel/MarginContainer/ViewportContainer/LevelSimulator/Camera2D

onready var FileMenu = $MarginContainer/VBoxContainer/MenuContainer/FileButton
onready var EditMenu = $MarginContainer/VBoxContainer/MenuContainer/EditButton
onready var ObjectEditMenu = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HBoxContainer/ObjectEditMenu
onready var AddPrefabButton = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HBoxContainer/AddPrefabButton
onready var AddObjectButton = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HBoxContainer/AddObjectButton

onready var TimeBar = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/ScrollContainer/Control/TimeBar
onready var ObjectNodeContainer = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/ScrollContainer/Control/ObjectNodeContainer
onready var TimelineView = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/ScrollContainer/Control
onready var LayersContainer = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/LayersContainer
onready var StartingLayer = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/LayersContainer/Layer
onready var TimelineExtraSpace = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/LayersContainer/ExtraScrollSpace
onready var TimelineHorizontalScroll = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/ScrollContainer/HSplitContainer/ScrollContainer
onready var ZoomSlider = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/BottomTimelineContainer/HBoxContainer/ZoomSlider
onready var PanSlider = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/VSplitContainer/BottomTimelineContainer/HBoxContainer/PanSlider

onready var PropertiesContainer = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties
onready var PropertiesSelectedLabel = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ObjectNameLabel

onready var ParentTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/ParentKey
onready var PosXTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/PosXKey
onready var PosYTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/PosYKey
onready var RotationTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/RotationKey
onready var ScaleXTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/ScaleXKey
onready var ScaleYTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/ScaleYKey
onready var ColorTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/ColorKey
onready var DestructableTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/DestructableKey
onready var BulletSolidTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/BulletSolidKey
onready var ZIndexTrackKey = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ScrollContainer/Properties/ZIndexKey

enum FileOptions {IMPORT_SONG = 0, IMPORT_LEVEL = 1, SAVE = 2, TEST = 3, EXPORT = 4}
enum ObjectEditOptions {DELETE = 0}

const SimulatorSize = Vector2(1920,1080)
const MAX_ITERATIONS = 35

var LevelTime = 10
var CurrentLevelTime = 0
var object_nodes = []
var enemy_nodes = []
var history = []
var layers = []
var layer_node = preload("res://Scenes/Editor/Layer.tscn")

var snap = 0.5
var zoom_level = 0
var time_scale = 1

var original_min_timeline_stretch
var min_timeline_stretch

var original_max_timeline_stretch
var max_timeline_stretch

var SelectedObject
var CopiedObject

var SelectedTrack

var SelectedKeyFrame
var CopiedKeyFrame

var SelectedShape

func _ready():
	
	Input.set_custom_mouse_cursor(null)
	CrossHair.hide_crosshair()
	
	SimulatorCamera.position = OS.get_screen_size()/2
	
	var _err
	_err = ObjectEditMenu.get_popup().connect("id_pressed",self,"ObjectEditMenuSelected")
	_err = FileMenu.get_popup().connect("id_pressed",self,"FileMenuSelected")
	
	layers.append(StartingLayer)
	
	min_timeline_stretch = TimelineView.rect_size.x
	original_min_timeline_stretch = min_timeline_stretch
	
	time_scale = (TimelineView.rect_min_size.x) / LevelTime
	zoom_timeline(1/101)
	

func _process(_delta):
	
	if Simulator.size != SimulatorSize:
		Simulator.size = SimulatorSize
	


func save_level():
	pass


func _on_ExitButton_pressed():
	#Ask to save
	
	Input.set_custom_mouse_cursor(CrossHair.get_inGame_Cursor())
	CrossHair.show_crosshair()
	SceneManager.load_scene(TitleScene,SceneManager.TransitionType.OUTZOOMOUTWARDSPIN)
	


func add_object_node(object : PackedScene = DefaultObject, object_name : String = "Object"):
	var new_node = NodeObject.instance()
	var new_object = object.instance()
	
	new_node.object = new_object
	new_node.set_manager(self)
	
	new_node.set_name(ensure_object_unique_names(object_name, new_node))
	
	ObjectNodeContainer.add_child(new_node)
	
	Simulator.add_child(new_object)
	
	scale_object_node(new_node)
	
	object_nodes.append(new_node)
	


func signal_object_focused(_object):
	SelectedObject = _object
	PropertiesSelectedLabel.text = _object.name
	
	ParentTrackKey.pressed = _object.parent_track_active
	PosXTrackKey.pressed = _object.positionx_track_active
	PosYTrackKey.pressed = _object.positiony_track_active
	RotationTrackKey.pressed = _object.rotation_track_active
	ScaleXTrackKey.pressed = _object.scalex_track_active
	ScaleYTrackKey.pressed = _object.scaley_track_active
	ColorTrackKey.pressed = _object.color_track_active
	DestructableTrackKey.pressed = _object.destructable_track_active
	BulletSolidTrackKey.pressed = _object.bullet_track_active
	ZIndexTrackKey.pressed = _object.z_track_active
	


func signal_object_name_changed(n, _object):
	_object.set_name(ensure_object_unique_names(n, _object))
	_object.NameLabel.text = _object.name
	PropertiesSelectedLabel.text = _object.name


func signal_track_focused(_track):
	SelectedTrack = _track
	print("track")


func signal_keyframe_focused(_keyframe):
	SelectedKeyFrame = _keyframe
	print("key")


func _on_TimeBar_value_changed(value):
	CurrentLevelTime = LevelTime * (value / TimeBar.max_value)
	update_level(CurrentLevelTime)


func update_level(time):
	for o in object_nodes:
		pass



func _on_AddObjectButton_pressed():
	add_object_node()


func _on_AddLayerButton_pressed():
	var new_layer = layer_node.instance()
	new_layer.text = ensure_layer_unique_names("Layer1")
	new_layer.set_prev_text(new_layer.text)
	layers.append(new_layer)
	new_layer.call_deferred("grab_focus")
	new_layer.select_all()
	LayersContainer.add_child(new_layer)
	TimelineExtraSpace.raise()


func ensure_object_unique_names(n : String, object):
	
	for o in object_nodes:
		
		if o.get_instance_id() == object.get_instance_id(): continue
		
		if o.name.dedent().to_lower() == n.dedent().to_lower():
			
			var new_name = n
			var new_end = n.substr(n.length()-1)
			
			if new_end.is_valid_integer():
				var iter = 1
				
				while new_end.is_valid_integer():
					iter += 1
					var end = n.length() - iter
					new_end = n.substr(end)
					new_name = n.substr(0,end+1)
				
				var new_num = int(new_end)
				return ensure_object_unique_names(new_name + str(new_num+1), object)
				
			return ensure_object_unique_names(n + "1", object)
			
		
	
	return n


func ensure_layer_unique_names(n : String):
	
	for l in layers:
		
		if l.text.dedent().to_lower() == n.dedent().to_lower():
			
			var new_name = n
			var new_end = n.substr(n.length()-1)
			
			if new_end.is_valid_integer():
				var iter = 1
				
				while new_end.is_valid_integer():
					iter += 1
					var end = n.length() - iter
					new_end = n.substr(end)
					new_name = n.substr(0,end+1)
				
				var new_num = int(new_end)
				return ensure_layer_unique_names(new_name + str(new_num+1))
				
			
			return ensure_layer_unique_names(n + "1")
			
		
	
	return n
	


func FileMenuSelected(id : int):
	
	match id:
		FileOptions.IMPORT_SONG:
			
			FileSelector.window_title = "Import Song"
			FileSelector.filters = ["*.ogg"]
			FileSelector.show()
			
		_:
			pass


func ObjectEditMenuSelected(id : int):
	
	match id:
		_:
			pass


func _on_ZoomSlider_value_changed(value):
	zoom_timeline(value / ZoomSlider.max_value)

#percent * LevelTime = time scale
func zoom_timeline(percent : float):
	
	zoom_level = percent * LevelTime
	if zoom_level < 1: zoom_level = 1 #THE FUCKING FIX FOR FUCKS SAKE
	
	TimelineView.rect_min_size.x = min_timeline_stretch * (zoom_level)
	TimelineView.rect_size.x = TimelineView.rect_min_size.x
	
	time_scale = (TimelineView.rect_min_size.x) / LevelTime
	for o in object_nodes:
		scale_object_node(o)
	pass


func _on_ParentKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.PARENT, button_pressed)


func _on_ParentInput_item_selected(index):
	if SelectedObject == null: return
	


func _on_PosXKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.POSITION, button_pressed)


func _on_PosXInput_value_changed(value):
	if SelectedObject == null: return
	
	if !SelectedObject.positionx_track_active:
		SelectedObject.toggle_track(ObjectNode.Tracks.POSITION, true)
	
	var key = SelectedObject.has_keyframe_at_time(ObjectNode.Tracks.POSITION, CurrentLevelTime)
	if key:
		key.values = value
		return
	
	SelectedObject.add_keyframe(ObjectNode.Tracks.POSITION, CurrentLevelTime, value)
	


func _on_PosYKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.POSITION, button_pressed, false)


func _on_PosYInput_value_changed(value):
	if SelectedObject == null: return
	
	if !SelectedObject.positiony_track_active:
		SelectedObject.toggle_track(ObjectNode.Tracks.POSITION, true)
	
	var key = SelectedObject.has_keyframe_at_time(ObjectNode.Tracks.POSITION, CurrentLevelTime, false)
	if key:
		key.values = value
		return
	
	SelectedObject.add_keyframe(ObjectNode.Tracks.POSITION, CurrentLevelTime, value, false)
	

func _on_ScaleXKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.SCALE, button_pressed)


func _on_ScaleXInput_value_changed(value):
	if SelectedObject == null: return


func _on_ScaleYKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.SCALE, button_pressed, false)


func _on_ScaleYInput_value_changed(value):
	if SelectedObject == null: return


func _on_RotationKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.ROTATION, button_pressed)


func _on_RotationInput_value_changed(value):
	if SelectedObject == null: return


func _on_ColorKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.COLOR, button_pressed)


func _on_ColorInput_color_changed(color):
	if SelectedObject == null: return


func _on_DestructableKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.DESTRUCTABLE, button_pressed)


func _on_DestructableInput_toggled(button_pressed):
	if SelectedObject == null: return


func _on_BulletSolidKey_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.BULLET_SOLID, button_pressed)


func _on_BulletSolidInput_toggled(button_pressed):
	if SelectedObject == null: return


func _on_Z_Index_Key_toggled(button_pressed):
	if SelectedObject == null: return
	SelectedObject.toggle_track(ObjectNode.Tracks.Z_INDEX, button_pressed)


func _on_ZInput_value_changed(value):
	if SelectedObject == null: return


func _on_HSplitContainer_dragged(offset):
	min_timeline_stretch = original_min_timeline_stretch - offset


func _on_FileDialog_file_selected(path):
	pass # Replace with function body.


func _on_PanSlider_value_changed(value):
	TimelineHorizontalScroll.scroll_horizontal = (value / PanSlider.max_value) * TimelineView.rect_size.x
	
	for o in object_nodes:
		if o.Properties.visible:
			o.position_Properties()
	

func scale_object_node(o):
	
	o.rect_position.x = (time_scale * o.spawn_time)
	
	o.rect_size.x = (time_scale * o.despawn_time) - (o.rect_position.x)
	
	if o.Properties.visible:
		o.position_Properties()
	
