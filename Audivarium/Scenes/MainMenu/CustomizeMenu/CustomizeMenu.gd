extends Node2D

var TitleScene = preload("res://Scenes/MainMenu/TitleMenu/TitleMain.tscn")
onready var Player = $Player
onready var PlayerColor1Input = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/PlayerColor1/PlayerColor1Input
onready var CrossHairColorInput = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/CrossHair/CrossHairInput
onready var TeleportColorInput = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/Teleport/TeleportInput
onready var TeleportCooldownColorInput = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/TeleportCooldown/TeleportCooldownInput
onready var DashColorInput = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/Dash/DashInput
onready var ReloadColorInput = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/Reload/ReloadInput
onready var BulletColorInput = $MenuOptions/MarginContainer/ScrollContainer/VBoxContainer/Bullet/BulletInput
onready var Menu = $MenuOptions/MarginContainer
onready var Square = $PlayerWalls/ColorRect

func _ready():
	PlayerColor1Input.color = PlayerGlobals.ColorPlayerMain
	CrossHairColorInput.color = PlayerGlobals.ColorCrossHair
	TeleportColorInput.color = PlayerGlobals.ColorTeleportIndicator
	TeleportCooldownColorInput.color = PlayerGlobals.ColorTeleportResetProgress
	DashColorInput.color = PlayerGlobals.ColorDashResetProgress
	ReloadColorInput.color = PlayerGlobals.ColorFireDelayProgress
	BulletColorInput.color = PlayerGlobals.ColorBullet


func _on_PlayerColor1Input_color_changed(color):
	PlayerGlobals.ColorPlayerMain = color
	Player.MainSprite.self_modulate = color


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
	if event.is_action("dash"):
		var focus = Menu.get_focus_owner()
		if focus:
			focus.release_focus()
		return
	


func _on_ExitButton_pressed():
	_exit_menu()


func _exit_menu():
	SceneManager.change_to_preloaded(TitleScene, SceneManager.TransitionType.INOUTSLIDELEFT)


func _on_BGInput_color_changed(color):
	Square.color = color
