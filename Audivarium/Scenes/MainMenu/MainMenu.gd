extends Node2D

func _ready():
	pass


func _on_LevelSelectButton_pressed():
	
	SceneManager.load_scene("res://Objects/Player/Player.tscn")
	
