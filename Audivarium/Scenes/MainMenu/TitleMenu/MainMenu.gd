extends Node2D

const LevelSelectScene = ("res://Objects/Player/Player.tscn")
const CustomizeScene = ("res://Scenes/MainMenu/CustomizeMenu/CustomizeMenu.tscn")
const SettingsScene = ("res://Scenes/MainMenu/SettingsMenu/SettingsMenu.tscn")
const EditorScene = "res://Scenes/Editor/LevelEditor.tscn"

onready var can_select = true

func _on_LevelSelectButton_pressed():
	if !can_select: return
	can_select = false
	SceneManager.load_scene(LevelSelectScene,SceneManager.TransitionType.OUTSLIDEUP)
	#SceneManager.change_to_preloaded(LevelSelectScene,SceneManager.TransitionType.OUTSLIDEUP)
	


func _on_CustomizeButton_pressed():
	if !can_select: return
	can_select = false
	
	SceneManager.load_scene(CustomizeScene,SceneManager.TransitionType.INFALLZOOMINWARD)
	


func _on_SettingsButton_pressed():
	if !can_select: return
	can_select = false
	
	SceneManager.load_scene(SettingsScene,SceneManager.TransitionType.INOUTSLIDERIGHT)
	


func _on_EditorButton_pressed():
	if !can_select: return
	can_select = false
	
	SceneManager.load_scene(EditorScene, SceneManager.TransitionType.INFALLZOOMINWARD)
