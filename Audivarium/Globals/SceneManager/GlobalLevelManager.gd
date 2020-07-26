extends Node

var loaded_level_directory
var loaded_level_info = Dictionary()
var loaded_level


func _ready():
	
	get_level("res://Objects/Bullets/MachineGun/")


func get_level(dir_path):
	var directory = Directory.new()
	if directory.open(dir_path) != OK: return
	
	loaded_level_directory = dir_path
	
	var file = File.new()
	
	directory.list_dir_begin()
	
	var file_name = directory.get_next()
	
	while file_name != "":
		
		file.open(dir_path + file_name, File.READ)
		
		if file_name == GlobalConstants.FILE_NAME_LEVEL_INFO:
			
			var data = file.get_as_text()
			data = JSON.parse(data)
			
			if data.error == OK: 
				
				data = data.result
				
				if data is Dictionary: 
					
					collect_info(data)
					file.close()
					break
					
				
			
		
		
		file.close()
		file_name = directory.get_next()
		
	
	directory.list_dir_end()
	


func collect_info(data):
	
	loaded_level_info.clear()
	var variable = data.get(GlobalConstants.KEY_LEVEL_NAME)
	
	loaded_level_info = {
	GlobalConstants.KEY_LEVEL_NAME : data.get(GlobalConstants.KEY_LEVEL_NAME),
	GlobalConstants.KEY_LEVEL_PATH : data.get(GlobalConstants.KEY_LEVEL_PATH),
	GlobalConstants.KEY_LEVEL_LENGTH : data.get(GlobalConstants.KEY_LEVEL_LENGTH),
	GlobalConstants.KEY_LEVEL_DESCRIPTION : data.get(GlobalConstants.KEY_LEVEL_DESCRIPTION),
	GlobalConstants.KEY_LEVEL_SONG_NAME : data.get(GlobalConstants.KEY_LEVEL_SONG_NAME),
	GlobalConstants.KEY_LEVEL_SONG_PATH : data.get(GlobalConstants.KEY_LEVEL_SONG_PATH),
	GlobalConstants.KEY_LEVEL_SONG_OFFSET : data.get(GlobalConstants.KEY_LEVEL_SONG_OFFSET),
	GlobalConstants.KEY_LEVEL_TYPE : data.get(GlobalConstants.KEY_LEVEL_TYPE),
	GlobalConstants.KEY_LEVEL_BG : data.get(GlobalConstants.KEY_LEVEL_BG),
	GlobalConstants.KEY_LEVEL_INFO_PALETTE : data.get(GlobalConstants.KEY_LEVEL_INFO_PALETTE),
	}
	
	


func load_level():
	
	var level_path = loaded_level_directory + loaded_level_info.get(GlobalConstants.KEY_LEVEL_PATH)
	
	
