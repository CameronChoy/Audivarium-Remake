extends Control

const Title = "res://Scenes/MainMenu/TitleMenu/TitleMain.tscn"

onready var SaveConfirm = $SaveConfirmation
var ConfirmButton
var CancelButton

var original_settings
var current_settings
onready var settings_changed = true

func _ready():
	
	ConfirmButton = SaveConfirm.get_ok()
	CancelButton = SaveConfirm.add_cancel("No")
	
	ConfirmButton.text = "Yes"
	var  _err = CancelButton.connect("pressed",self,"_on_SaveConfirmation_deny")
	


func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if settings_changed:
			SaveConfirm.visible = !SaveConfirm.visible
		
	elif event.is_action_pressed("ui_accept"):
		if SaveConfirm.visible:
			_on_SaveConfirmation_confirmed()


func _apply_settings():
	pass


func _revert_settings():
	pass


func _save_settings():
	pass


func _load_settings():
	pass


func _exit_settings():
	SceneManager.load_scene(Title, SceneManager.TransitionType.INSLIDERIGHT)


func _on_SaveConfirmation_confirmed():
	_save_settings()
	_exit_settings()

func _on_SaveConfirmation_deny():
	_exit_settings()


func _on_ExitButton_pressed():
	
	if settings_changed:
		SaveConfirm.show()
	else:
		_exit_settings()
	
