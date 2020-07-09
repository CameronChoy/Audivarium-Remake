extends Node2D

var LevelSelectScene = preload("res://Objects/Player/Player.tscn")

func _ready():
	pass


func _on_LevelSelectButton_pressed():
	
	#SceneManager.load_scene("res://Objects/Player/Player.tscn",SceneManager.TransitionType.INOUTSLIDEUP)
	SceneManager.change_to_preloaded(LevelSelectScene,SceneManager.TransitionType.OUTSLIDERIGHT)
