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
