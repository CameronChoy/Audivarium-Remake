extends Node
onready var Resume = $PauseMenu/VBoxContainer/GridContainer/Resume
onready var Quit = $PauseMenu/VBoxContainer/GridContainer/Quit
onready var Settings = $PauseMenu/VBoxContainer/GridContainer/Settings
onready var PauseLabel = $PauseMenu/VBoxContainer/Label 

func hide():
	$PauseMenu.hide()

func show():
	$PauseMenu.show()

func toggle_visibility(new : bool):
	$PauseMenu.visible = new

func _focused_audio():
	if SceneManager.moving_scene: return
	GlobalAudio.play_audio(GlobalAudio.audio_focus)

func _lose_focus_audio():
	GlobalAudio.play_audio(GlobalAudio.audio_unfocus)

func _selected_audio():
	GlobalAudio.play_audio(GlobalAudio.audio_select)
