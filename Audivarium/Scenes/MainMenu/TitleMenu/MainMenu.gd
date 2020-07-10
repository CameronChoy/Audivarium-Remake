extends Node2D

var LevelSelectScene = preload("res://Objects/Player/Player.tscn")
var CustomizeScene = preload("res://Scenes/MainMenu/CustomizeMenu/CustomizeMenu.tscn")
var SettingsScene = preload("res://Scenes/MainMenu/SettingsMenu/SettingsMenu.tscn")

onready var can_select = true


func _on_LevelSelectButton_pressed():
	if !can_select: return
	can_select = false
	
	SceneManager.change_to_preloaded(LevelSelectScene,SceneManager.TransitionType.OUTSLIDEUP)
	


func _on_CustomizeButton_pressed():
	if !can_select: return
	can_select = false
	
	SceneManager.change_to_preloaded(CustomizeScene,SceneManager.TransitionType.INFALLZOOMINWARD)
	


func _on_SettingsButton_pressed():
	if !can_select: return
	can_select = false
	
	SceneManager.change_to_preloaded(SettingsScene,SceneManager.TransitionType.INOUTSLIDERIGHT)
	
