extends Node2D

const LevelSelectScene = ("res://Scenes/LevelSelect/LevelSelect.tscn")
const CustomizeScene = ("res://Scenes/MainMenu/CustomizeMenu/CustomizeMenu.tscn")
const SettingsScene = ("res://Scenes/MainMenu/SettingsMenu/SettingsMenu.tscn")
const EditorScene = "res://Scenes/Editor/LevelEditor.tscn"
onready var QuitConfirm = $MainControl/QuitConfirmation
onready var quitting = false


func _on_LevelSelectButton_pressed():
	SceneManager.load_scene(LevelSelectScene,SceneManager.TransitionType.OUTSLIDEUP)
	


func _on_CustomizeButton_pressed():
	SceneManager.load_scene(CustomizeScene,SceneManager.TransitionType.INFALLZOOMINWARD)
	


func _on_SettingsButton_pressed():
	SceneManager.load_scene(SettingsScene,SceneManager.TransitionType.INOUTSLIDERIGHT)
	


func _on_EditorButton_pressed():
	SceneManager.load_scene(EditorScene, SceneManager.TransitionType.INFALLZOOMINWARD)
	


func _on_QuitButton_pressed():
	QuitConfirm.show()
	quitting = true


func _on_QuitConfirmation_confirmed():
	get_tree().quit()


func _input(event):
	
	if event.is_action_pressed("ui_accept") and quitting:
		get_tree().quit()
		
	elif event.is_action_pressed("ui_cancel"):
		QuitConfirm.visible = !QuitConfirm.visible
		quitting = QuitConfirm.visible
		
	
