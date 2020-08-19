extends Node2D

const LevelSelectScene = ("res://Scenes/LevelSelect/LevelSelect.tscn")
const CustomizeScene = ("res://Scenes/MainMenu/CustomizeMenu/CustomizeMenu.tscn")
const SettingsScene = ("res://Scenes/MainMenu/SettingsMenu/SettingsMenu.tscn")
const EditorScene = "res://Scenes/Editor/LevelEditor.tscn"
onready var TitleAnim = $Title/AnimationPlayer
onready var QuitConfirm = $MainControl/QuitConfirmation
onready var quitting = false

func _ready():
	randomize()
	$Title.self_modulate = Color(randf(),randf(),randf(),1.0)
	TitleAnim.play("loop")
	TitleAnim.seek(randf() * TitleAnim.get_animation("loop").get_length())


func _on_LevelSelectButton_pressed():
	_selected_audio()
	SceneManager.load_scene(LevelSelectScene,SceneManager.TransitionType.OUTSLIDEUP, CrossHair.CrossHairFrame.THREE)
	


func _on_CustomizeButton_pressed():
	_selected_audio()
	SceneManager.load_scene(CustomizeScene,SceneManager.TransitionType.INFALLZOOMINWARD, CrossHair.CrossHairFrame.FOUR)
	


func _on_SettingsButton_pressed():
	_selected_audio()
	SceneManager.load_scene(SettingsScene,SceneManager.TransitionType.INOUTSLIDERIGHT, CrossHair.CrossHairFrame.THREE)
	


func _on_EditorButton_pressed():
	_selected_audio()
	SceneManager.load_scene(EditorScene, SceneManager.TransitionType.INFALLZOOMINWARD,CrossHair.CrossHairFrame.TWO)
	


func _on_QuitButton_pressed():
	_selected_audio()
	QuitConfirm.show()
	quitting = true


func _on_QuitConfirmation_confirmed():
	get_tree().queue_delete(get_tree())


func _input(event):
	
	if event.is_action_pressed("ui_accept") and quitting:
		_on_QuitConfirmation_confirmed()
		
	elif event.is_action_pressed("ui_cancel"):
		QuitConfirm.visible = !QuitConfirm.visible
		quitting = QuitConfirm.visible
		
	


func _focused():
	if SceneManager.moving_scene: return
	GlobalAudio.play_audio(GlobalAudio.audio_focus)

func _lose_focus():
	GlobalAudio.play_audio(GlobalAudio.audio_unfocus)

func _selected_audio():
	GlobalAudio.play_audio(GlobalAudio.audio_select)

