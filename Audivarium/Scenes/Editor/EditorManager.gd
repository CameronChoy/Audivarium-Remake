extends Node2D

const TitleScene = "res://Scenes/MainMenu/TitleMenu/TitleMain.tscn"
var saved

var ObjectNode = preload("res://Scenes/Editor/ObjectNode.tscn")
var DefaultObject = preload("res://Objects/Statics/Circle.tscn")

onready var Simulator = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/LevelDisplayContainer/Panel/MarginContainer/ViewportContainer/LevelSimulator
onready var SimulatorCamera = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/LevelDisplayContainer/Panel/MarginContainer/ViewportContainer/LevelSimulator/Camera2D

onready var FileMenu = $MarginContainer/VBoxContainer/MenuContainer/FileButton
onready var EditMenu = $MarginContainer/VBoxContainer/MenuContainer/EditButton
onready var ObjectEditMenu = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HBoxContainer/ObjectEditMenu
onready var AddPrefabButton = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HBoxContainer/AddPrefabButton
onready var AddObjectButton = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HBoxContainer/AddObjectButton

#onready var TimelineView = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/ViewportContainer/TimelineViewport 
onready var TimeBar = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/ScrollContainer/HSplitContainer/Control/TimeBar
onready var ObjectNodeContainer = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/ScrollContainer/HSplitContainer/Control/ObjectNodeContainer
onready var LayersContainer = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/ScrollContainer/HSplitContainer/LayersContainer
onready var StartingLayer = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/ScrollContainer/HSplitContainer/LayersContainer/Layer
onready var TimelineExtraSpace = $MarginContainer/VBoxContainer/MainUISplitter/BottomContainer/Panel/VBoxContainer/HSplitContainer/TimelinePanel/ScrollContainer/HSplitContainer/LayersContainer/ExtraScrollSpace

onready var PropertiesSelectedLabel = $MarginContainer/VBoxContainer/MainUISplitter/TopContainer/WindowUISplitter/UISplitter/PropertiesContainer/Panel/MarginContainer/VBoxContainer/ObjectNameLabel

enum FileOptions {IMPORT_SONG = 0, IMPORT_LEVEL = 1, SAVE = 2, TEST = 3}
enum ObjectEditOptions {DELETE = 0}

const SimulatorSize = Vector2(1920,1080)
const MAX_ITERATIONS = 35

var LevelTime = 0
var CurrentLevelTime = 0
var object_nodes = []
var enemy_nodes = []
var history = []
var layers = []
var layer_node = preload("res://Scenes/Editor/Layer.tscn")

var SelectedObject
var CopiedObject
var SelectedKeyFrame
var CopiedKeyFrame

func _ready():
	Input.set_custom_mouse_cursor(null)
	CrossHair.hide_crosshair()
	SimulatorCamera.position = OS.get_screen_size()/2
	ObjectEditMenu.get_popup().connect("id_pressed",self,"ObjectEditMenuSelected")
	layers.append(StartingLayer)
	

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
	var new_node = ObjectNode.instance()
	var new_object = DefaultObject.instance()
	new_node.object = new_object
	new_node.set_manager(self)
	new_node.set_name(ensure_object_unique_names(object_name, new_node))
	ObjectNodeContainer.add_child(new_node)
	Simulator.add_child(new_object)
	object_nodes.append(new_node)
	


func signal_object_focused(_object):
	SelectedObject = _object
	PropertiesSelectedLabel.text = _object.name


func signal_object_name_changed(n, _object):
	_object.set_name(ensure_object_unique_names(n, _object))
	_object.NameLabel.text = _object.name


func _on_TimeBar_value_changed(value):
	CurrentLevelTime = LevelTime * (value / TimeBar.max_value)
	update_level(CurrentLevelTime)


func update_level(time):
	for o in object_nodes:
		pass


func _on_ParentKey_toggled(button_pressed):
	if SelectedObject == null: return
	var index = SelectedObject.parent_points.find(CurrentLevelTime)
	
	if button_pressed:
		pass
	else:
		pass
	


func ObjectEditMenuSelected(id : int):
	
	match id:
		_:
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
				return ensure_layer_unique_names(new_name + str(new_num+1))
				
			return ensure_layer_unique_names(n + "1")
			
		
	
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
	


func _on_ParentInput_item_selected(index):
	if SelectedObject == null: return


func _on_PosXKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_PosXInput_value_changed(value):
	if SelectedObject == null: return


func _on_PosYKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_PosYInput_value_changed(value):
	if SelectedObject == null: return


func _on_ScaleXKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_ScaleXInput_value_changed(value):
	if SelectedObject == null: return


func _on_ScaleYKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_ScaleYInput_value_changed(value):
	if SelectedObject == null: return


func _on_RotationKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_RotationInput_value_changed(value):
	if SelectedObject == null: return


func _on_ColorKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_ColorInput_color_changed(color):
	if SelectedObject == null: return


func _on_DestructableKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_DestructableInput_toggled(button_pressed):
	if SelectedObject == null: return


func _on_BulletSolidKey_toggled(button_pressed):
	if SelectedObject == null: return


func _on_BulletSolidInput_toggled(button_pressed):
	if SelectedObject == null: return


func _on_Z_Index_Key_toggled(button_pressed):
	if SelectedObject == null: return


func _on_ZInput_value_changed(value):
	if SelectedObject == null: return



