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
	_selected_audio()
	SceneManager.load_scene(LevelScene, SceneManager.TransitionType.OUTZOOMOUTWARDSPIN, CrossHair.CrossHairFrame.FOUR)


func _on_ExitButton_pressed():
	_selected_audio()
	SceneManager.load_scene(LevelSelect, SceneManager.TransitionType.INSLIDERIGHT, CrossHair.CrossHairFrame.THREE)


func _focused():
	if SceneManager.moving_scene: return
	GlobalAudio.play_audio(GlobalAudio.audio_focus)

func _lose_focus():
	GlobalAudio.play_audio(GlobalAudio.audio_unfocus)

func _selected_audio():
	GlobalAudio.play_audio(GlobalAudio.audio_select)
