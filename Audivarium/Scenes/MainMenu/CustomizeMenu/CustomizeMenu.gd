extends Node2D

var TitleScene = preload("res://Scenes/MainMenu/TitleMenu/TitleMain.tscn")

onready var Player = $Player
onready var PlayerColor1Input = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/PlayerColor1/PlayerColor1Input
onready var PlayerColor2Input = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/PlayerColor2/PlayerColor2Input
onready var PlayerColor3Input = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/PlayerColor3/PlayerColor3Input
onready var CrossHairColorInput = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/CrossHair/CrossHairInput
onready var TeleportColorInput = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/Teleport/TeleportInput
onready var TeleportCooldownColorInput = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/TeleportCooldown/TeleportCooldownInput
onready var DashColorInput = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/Dash/DashInput
onready var ReloadColorInput = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/Reload/ReloadInput
onready var BulletColorInput = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/Bullet/BulletInput
onready var Menu = $MenuOptions/MarginContainer
onready var Square = $PlayerWalls/CanvasLayer/ColorRect
onready var PlayerBodies = $MenuOptions/MarginContainer/CenterContainer/ScrollContainer/VBoxContainer/PlayerBodies

const PATH_PLAYER_BODIES = "res://Objects/Player/PlayerBodies/PlayerBodies"

var thread
var loaded_bodies = []
signal body_color_changed

func _ready():
	
	PlayerColor1Input.color = PlayerGlobals.PlayerColors[0]
	PlayerColor2Input.color = PlayerGlobals.PlayerColors[clamp(1,0,PlayerGlobals.PlayerColors.size()-1)]
	PlayerColor3Input.color = PlayerGlobals.PlayerColors[clamp(2,0,PlayerGlobals.PlayerColors.size()-1)]
	CrossHairColorInput.color = PlayerGlobals.ColorCrossHair
	TeleportColorInput.color = PlayerGlobals.ColorTeleportIndicator
	TeleportCooldownColorInput.color = PlayerGlobals.ColorTeleportResetProgress
	DashColorInput.color = PlayerGlobals.ColorDashResetProgress
	ReloadColorInput.color = PlayerGlobals.ColorFireDelayProgress
	BulletColorInput.color = PlayerGlobals.ColorBullet
	Player.fire_while_focused = false
	
	thread = Thread.new()
	#var _err = connect("thread_complete",self,"_thread_complete")
	var _err = thread.start(self,"_add_bodies", 0)
	
	_err = connect("body_color_changed", self, "_color_changed")
	


func _add_bodies(_err):
	var directory = Directory.new()
	
	if directory.open(PATH_PLAYER_BODIES) != OK: 
		directory.make_dir_recursive(PATH_PLAYER_BODIES)
		return
	
	directory.list_dir_begin()
	var file_name = directory.get_next()
	
	while file_name != "":
		if file_name == "template.tscn" : continue
		
		var file_path = "%s/%s" % [PATH_PLAYER_BODIES, file_name]
		file_name = directory.get_next()
		
		if !ResourceLoader.exists(file_path): continue
		
		_create_button(file_path)
		
	
	directory.list_dir_end()
	return thread
	


func _create_button(file_path):
	var pack = ResourceLoader.load(file_path)
	var body = pack.instance()
	if not body is PlayerBody : return
	
	var button = Button.new()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.rect_min_size.y = 100
	PlayerBodies.add_child(button)
	
	body.set_colors(PlayerGlobals.get_PlayerColors())
	loaded_bodies.append(body)
	
	button.add_child(body)
	body.position.y = button.rect_size.y / 2
	body.position.x = 125
	
	button.connect("pressed",self,"_body_selected",[pack])
	


func _thread_complete():
	var _err = thread.wait_to_finish()


func _body_selected(body):
	Player.set_body_sprite(body)
	


func _color_changed(index, color):
	PlayerGlobals.PlayerColors[index] = color
	Player.set_body_modulate(index, color)
	
	for body in loaded_bodies:
		body.set_single_color(index, color)
	


func _on_PlayerColor1Input_color_changed(color):
	emit_signal("body_color_changed", 0, color)


func _on_PlayerColor2Input_color_changed(color):
	emit_signal("body_color_changed", 1, color)


func _on_PlayerColor3Input_color_changed(color):
	emit_signal("body_color_changed", 2, color)


func _on_CrossHairInput_color_changed(color):
	PlayerGlobals.ColorCrossHair = color
	CrossHair.CrossHairSprite.self_modulate = color


func _on_TeleportInput_color_changed(color):
	PlayerGlobals.ColorTeleportIndicator = color
	Player.TeleportIndicator.self_modulate = color


func _on_TeleportCooldownInput_color_changed(color):
	PlayerGlobals.ColorTeleportResetProgress = color
	CrossHair.RadialProgressLeft.self_modulate = color


func _on_DashInput_color_changed(color):
	PlayerGlobals.ColorDashResetProgress = color
	CrossHair.RadialProgressRight.self_modulate = color


func _on_ReloadInput_color_changed(color):
	PlayerGlobals.ColorFireDelayProgress = color
	CrossHair.BarProgressRight.self_modulate = color


func _on_BulletInput_color_changed(color):
	PlayerGlobals.ColorBullet = color
	


func _input(event):
	if event.is_action_pressed("dash"):
		var focus = Menu.get_focus_owner()
		if focus:
			focus.release_focus()
		return
	
	if event.is_action_pressed("ui_cancel"):
		_exit_menu()
	


func _on_ExitButton_pressed():
	_exit_menu()


func _exit_menu():
	PlayerGlobals.save_player_values()
	SceneManager.change_to_preloaded(TitleScene, SceneManager.TransitionType.INOUTSLIDELEFT)


func _on_BGInput_color_changed(color):
	Square.color = color
