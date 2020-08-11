extends Control

export var exit_hides :  bool = false
var audio_test = preload("res://Objects/Bullets/Pistol/pistol_fire.wav")

const Title = "res://Scenes/MainMenu/TitleMenu/TitleMain.tscn"
const RESET_TIME = 15
enum Confirms {RESOLUTION}

var Resolutions = [
	Vector2(3840,2400),
	Vector2(2560,1440),
	Vector2(1920,1080),
	Vector2(1600,900),
	Vector2(1280,720),
	Vector2(1024,576)
]

onready var ResolutionInput = $TabContainer/Video/VBoxContainer/Resolution/ResolutionOptions
var prev_res_input
var current_reset_time = 0

onready var FullscreenInput = $TabContainer/Video/VBoxContainer/Fullscreen/FullscreenCheck
onready var BorderInput = $TabContainer/Video/VBoxContainer/Borderless/BorderCheck

onready var MasterVolumeLabel = $TabContainer/Audio/VBoxContainer/MasterVolume/volume
onready var MasterVolumeInput = $TabContainer/Audio/VBoxContainer/MasterVolume/HSplitContainer/HSlider

onready var SaveConfirm = $SaveConfirmation
onready var OptionConfirm = $OptionConfirm
onready var ConfirmTimer = $OptionConfirm/Timer
onready var current_confirm = RESET_TIME
var SaveConfirmButton
var SaveCancelButton
var SaveRevertCancelButton
var OptionConfirmButton
var OptionCancelButton

var original_settings
var current_settings
onready var settings_changed = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	CrossHair.set_mouse_escape(true)
	
	original_settings = GlobalSettings.get_settings()
	current_settings = original_settings
	
	SaveConfirmButton = SaveConfirm.get_ok()
	SaveRevertCancelButton = SaveConfirm.add_button("Don't save",true)
	SaveCancelButton = SaveConfirm.add_button("Cancel",true)
	
	SaveConfirmButton.text = "Save and exit"
	var _err = SaveCancelButton.connect("pressed",self,"_on_SaveConfirmation_deny")
	_err = SaveRevertCancelButton.connect("pressed",self,"_on_SaveConfirmation_revert_deny")
	
	OptionConfirmButton = OptionConfirm.get_ok()
	OptionCancelButton = OptionConfirm.add_button("Revert",true)
	
	OptionConfirmButton.text = "Keep"
	_err = OptionCancelButton.connect("pressed",self,"_on_OptionCornfirm_deny")
	
	
	var original_res = Vector2(original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_X),
	original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_Y))
	
	for i in range(Resolutions.size()):
		
		var res = Resolutions[i]
		ResolutionInput.add_item("%s X %s" % [res.x, res.y], i)
		
		if res == original_res:
			ResolutionInput.select(i)
			
		
	prev_res_input = ResolutionInput.get_item_index(ResolutionInput.get_selected_id())
	
	FullscreenInput.pressed = original_settings.get(GlobalConstants.KEY_SETTING_FULLSCREEN)
	BorderInput.pressed = original_settings.get(GlobalConstants.KEY_SETTING_BORDERLESS)
	


func _input(event):
	
	if event.is_action_pressed("ui_cancel"):
		if settings_changed:
			SaveConfirm.visible = !SaveConfirm.visible
		else:
			_exit_settings()
		
	elif event.is_action_pressed("ui_accept"):
		if SaveConfirm.visible:
			_on_SaveConfirmation_confirmed()
		elif OptionConfirm.visible:
			_on_OptionConfirm_confirmed()
		
	


func _revert_settings():
	_revert_resolution()
	OS.window_borderless = original_settings.get(GlobalConstants.KEY_SETTING_BORDERLESS)
	OS.window_fullscreen = original_settings.get(GlobalConstants.KEY_SETTING_FULLSCREEN)
	

func _exit_settings():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	CrossHair.set_mouse_escape(false)
	ConfirmTimer.stop()
	
	if exit_hides:
		hide()
	else:
		SceneManager.load_scene(Title, SceneManager.TransitionType.INSLIDERIGHT)
		
	


func _on_SaveConfirmation_confirmed():
	GlobalSettings.save_settings(current_settings)
	_exit_settings()
	


func _on_SaveConfirmation_deny():
	SaveConfirm.hide()
	


func _on_SaveConfirmation_revert_deny():
	_revert_settings()
	_exit_settings()
	


func _on_ExitButton_pressed():
	
	if settings_changed:
		SaveConfirm.window_title = "Save Settings?"
		SaveConfirm.dialog_text = ""
		SaveConfirm.show()
	else:
		_exit_settings()
	


func _on_ResolutionOptions_item_selected(index):
	
	if index != prev_res_input:
		prev_res_input = index
		OS.window_size = Resolutions[index]
		current_confirm = Confirms.RESOLUTION
		
		current_reset_time = RESET_TIME
		OptionConfirm.window_title = "Keep this resolution?"
		OptionConfirm.dialog_text = "\nAutomatically revert in: %s s" % [current_reset_time]
		OptionConfirm.show()
		ConfirmTimer.start(1)
		
	


func _on_Timer_timeout():
	
	current_reset_time -= 1
	if current_reset_time >= 0:
		OptionConfirm.dialog_text = "\nAutomatically revert in: %s s" % [current_reset_time]
	else:
		ConfirmTimer.stop()
		match current_confirm:
			Confirms.RESOLUTION:
				_revert_resolution()
			
		
	


func _revert_resolution():
	
	ConfirmTimer.stop()
	ResolutionInput.select(prev_res_input)
	
	OS.window_size = Vector2(original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_X),
		original_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_Y))
	


func _on_FullscreenCheck_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
	
	settings_changed = true
	current_settings[GlobalConstants.KEY_SETTING_FULLSCREEN] = OS.window_fullscreen
	


func _on_BorderCheck_pressed():
	OS.window_borderless = !OS.window_borderless
	OS.window_position = Vector2()
	settings_changed = true
	current_settings[GlobalConstants.KEY_SETTING_BORDERLESS] = OS.window_borderless
	


func _on_OptionConfirm_confirmed():
	
	OptionConfirm.hide()
	settings_changed = true
	
	match current_confirm:
		Confirms.RESOLUTION:
			current_settings[GlobalConstants.KEY_SETTING_RESOLUTION_X] = OS.window_size.x
			current_settings[GlobalConstants.KEY_SETTING_RESOLUTION_Y] = OS.window_size.y
		


func _on_OptionCornfirm_deny():
	
	ConfirmTimer.stop()
	OptionConfirm.hide()
	
	
	match current_confirm:
		Confirms.RESOLUTION:
			_revert_resolution()
		
	


func _on_HSlider_value_changed(value):
	MasterVolumeLabel.text = "%.2f" % [value]
	
	var inverse_val = 1.0 - value
	var new_db = (-60 * inverse_val)
	
	AudioServer.set_bus_volume_db(0,new_db)
	current_settings[GlobalConstants.KEY_SETTING_MASTER_DB] = new_db
	_test_audio()
	


func _test_audio():
	GlobalAudio.play_audio(audio_test)
