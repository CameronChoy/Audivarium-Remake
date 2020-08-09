extends Control

export var exit_hides :  bool = false

const Title = "res://Scenes/MainMenu/TitleMenu/TitleMain.tscn"
const RESET_TIME = 15
enum Confirms {EXIT, RESOLUTION}

var Resolutions = [
	Vector2(3840,2400),
	Vector2(2560,1440),
	Vector2(1920,1080),
	Vector2(1600,900),
	Vector2(1280,720),
	Vector2(1024,576)
]

onready var ResolutionInput = $TabContainer/Video/Resolution/ResolutionOptions
var prev_res_input
var current_reset_time = 0

onready var SaveConfirm = $SaveConfirmation
onready var ConfirmTimer = $SaveConfirmation/Timer
onready var current_confirm = RESET_TIME
var ConfirmButton
var CancelButton

var original_settings
var current_settings
onready var settings_changed = false

func _ready():
	
	original_settings = GlobalSettings.get_settings()
	current_settings = original_settings
	
	ConfirmButton = SaveConfirm.get_ok()
	CancelButton = SaveConfirm.add_cancel("No")
	
	ConfirmButton.text = "Yes"
	var  _err = CancelButton.connect("pressed",self,"_on_SaveConfirmation_deny")
	
	var original_res = Vector2(original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_X),
	original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_Y))
	
	for i in range(Resolutions.size()):
		
		var res = Resolutions[i]
		ResolutionInput.add_item("%s X %s" % [res.x, res.y], i)
		
		if res == original_res:
			ResolutionInput.select(i)
			
		
	prev_res_input = ResolutionInput.get_item_index(ResolutionInput.get_selected_id())
	


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


func _exit_settings():
	if exit_hides:
		hide()
	else:
		SceneManager.load_scene(Title, SceneManager.TransitionType.INSLIDERIGHT)
		
	


func _on_SaveConfirmation_confirmed():
	match current_confirm:
		Confirms.EXIT:
			GlobalSettings.save_settings(current_settings)
			_exit_settings()
		Confirms.RESOLUTION:
			ConfirmTimer.stop()
			current_settings[GlobalConstants.KEY_SETTING_RESOLUTION_X] = OS.window_size.x
			current_settings[GlobalConstants.KEY_SETTING_RESOLUTION_Y] = OS.window_size.y


func _on_SaveConfirmation_deny():
	match current_confirm:
		Confirms.EXIT:
			_exit_settings()
		Confirms.RESOLUTION:
			SaveConfirm.hide()
			_revert_resolution()
			
		
	


func _on_ExitButton_pressed():
	
	if settings_changed:
		current_confirm = Confirms.EXIT
		SaveConfirm.window_title = "Save Settings?"
		SaveConfirm.dialog_text = ""
		SaveConfirm.show()
	else:
		_exit_settings()
	


func _on_ResolutionOptions_item_selected(index):
	if index != prev_res_input:
		OS.window_size = Resolutions[index]
		settings_changed = true
		current_confirm = Confirms.RESOLUTION
		
		current_reset_time = RESET_TIME
		SaveConfirm.window_title = "Keep this resolution?"
		SaveConfirm.dialog_text = "\nAutomatically revert in: %s s" % [current_reset_time]
		SaveConfirm.show()
		ConfirmTimer.start(1)
		
	


func _on_Timer_timeout():
	
	current_reset_time -= 1
	if current_reset_time >= 0:
		SaveConfirm.dialog_text = "\nAutomatically revert in: %s s" % [current_reset_time]
	else:
		ConfirmTimer.stop()
		match current_confirm:
			Confirms.RESOLUTION:
				_revert_resolution()
			_:
				return

func _revert_resolution():
	
	ConfirmTimer.stop()
	ResolutionInput.select(prev_res_input)
	
	OS.window_size = Vector2(original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_X),
		original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_Y))
	
