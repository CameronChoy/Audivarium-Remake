extends Node

var current_settings
var settings_keys
var settings_path
var default_settings

func _ready():
	
	settings_path = "%s/%s" % [OS.get_user_data_dir(), GlobalConstants.FILE_NAME_SETTINGS]
	
	settings_keys = [
		GlobalConstants.KEY_SETTING_RESOLUTION_X,
		GlobalConstants.KEY_SETTING_RESOLUTION_Y,
		GlobalConstants.KEY_SETTING_FULLSCREEN,
		GlobalConstants.KEY_SETTING_BORDERLESS,
		GlobalConstants.KEY_SETTING_FPS,
		GlobalConstants.KEY_SETTING_VSYNC,
		GlobalConstants.KEY_SETTING_MASTER_DB,
		GlobalConstants.KEY_SETTING_EFFECTS_DB,
	]
	
	default_settings = {
		GlobalConstants.KEY_SETTING_RESOLUTION_X : 1920,
		GlobalConstants.KEY_SETTING_RESOLUTION_Y : 1080,
		GlobalConstants.KEY_SETTING_FULLSCREEN : true,
		GlobalConstants.KEY_SETTING_BORDERLESS : true,
		GlobalConstants.KEY_SETTING_FPS : 60,
		GlobalConstants.KEY_SETTING_VSYNC : true,
		GlobalConstants.KEY_SETTING_MASTER_DB : 0,
		GlobalConstants.KEY_SETTING_EFFECTS_DB : 0,
	}
	
	load_settings()
	_apply_settings()
	


func save_settings(new):
	if not new is Dictionary: return
	current_settings = new
	
	var file = File.new()
	
	if file.open(settings_path, File.WRITE) != OK: return
	
	file.store_string(to_json(new))
	


func load_settings():
	
	
	var file = File.new()
	
	if !file.file_exists(settings_path):
		set_settings_to_default(file)
		return
	
	if file.open(settings_path, File.READ_WRITE) != OK: return
	
	var info = JSON.parse(file.get_as_text())
	 
	
	if info.error != OK:
		print(info.error_string)
		file.close()
		return
	
	info = info.result
	if not info is Dictionary:
		set_settings_to_default(file)
		return
	
	
	current_settings = Dictionary()
	var missing = false
	for key in settings_keys:
		if info.has(key):
			current_settings[key] = info.get(key) 
		else:
			current_settings[key] = default_settings.get(key)
			missing = true
	
	if missing:
		file.store_string(to_json(current_settings))
	
	file.close()
	


func _apply_settings():
	
	OS.window_size = Vector2(current_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_X),
		current_settings.get(GlobalConstants.KEY_SETTING_RESOLUTION_Y))
	
	OS.window_fullscreen = bool(current_settings.get(GlobalConstants.KEY_SETTING_FULLSCREEN))
	OS.window_borderless = bool(current_settings.get(GlobalConstants.KEY_SETTING_BORDERLESS))
	
	Engine.target_fps = current_settings.get(GlobalConstants.KEY_SETTING_FPS)
	var phys = clamp(current_settings.get(GlobalConstants.KEY_SETTING_FPS),30,300)
	ProjectSettings.set_setting("physics/common/physics_fps",phys)
	
	AudioServer.set_bus_volume_db(0,current_settings.get(GlobalConstants.KEY_SETTING_MASTER_DB))
	


func set_settings_to_default(file):
	if not file is File or file.open(settings_path, File.WRITE) != OK: return
	
	file.store_string(to_json(default_settings))
	current_settings = default_settings
	file.close()
	


func get_settings():
	return current_settings

