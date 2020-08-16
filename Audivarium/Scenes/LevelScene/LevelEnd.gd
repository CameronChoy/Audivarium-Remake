extends Control

const LevelScene = "res://Scenes/LevelScene/LevelScene.tscn"
const LevelSelect = "res://Scenes/LevelSelect/LevelSelect.tscn"

onready var LevelStatus = $VBoxContainer/LevelStatus
export(Color) var Complete_Color = Color.green
export(Color) var Fail_Color = Color.red


func _ready():
	if GlobalLevelManager.level_completed:
		LevelStatus.text = "Level Completed"
		LevelStatus.self_modulate = Complete_Color
	else:
		LevelStatus.text = "Level Failed"
		LevelStatus.self_modulate = Fail_Color


func _on_ReplayButton_pressed():
	SceneManager.load_scene(LevelScene, SceneManager.TransitionType.OUTZOOMOUTWARDSPIN, CrossHair.CrossHairFrame.FOUR)


func _on_ExitButton_pressed():
	SceneManager.load_scene(LevelSelect, SceneManager.TransitionType.INSLIDERIGHT, CrossHair.CrossHairFrame.TWO)
