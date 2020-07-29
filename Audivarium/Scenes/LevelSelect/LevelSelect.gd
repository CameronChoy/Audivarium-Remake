extends Control

const OFFICIAL_LEVELS_PATH = "res://Scenes/Levels/OfficialLevels/"

var LevelButton = preload("res://Scenes/Levels/LevelButton.tscn")

onready var InfoCard1 = $InfoCards/Info1
onready var InfoCard2 = $InfoCards/Info2
onready var InfoAnim = $InfoCards/InfoCardsAnim
onready var OfficialsList = $LevelsList/TabContainer/Levels/Scroll/OfficialsList
onready var CustomsList = $LevelsList/TabContainer/CustomLevels/Scroll/CustomsList

var SelectedLevel
var PreviewSong
var officials_thread
var customs_thread

func _ready():
	
	officials_thread = Thread.new()
	var _err = officials_thread.start(self,"get_official_levels", 0)
	
	customs_thread = Thread.new()
	_err = customs_thread.start(self,"get_custom_levels", 0)
	
	


func get_official_levels(_err):
	
	var directory = Directory.new()
	var levels_path = OFFICIAL_LEVELS_PATH
	
	if directory.open(levels_path) != OK: return
	
	directory.list_dir_begin()
	var dir_name = directory.get_next()
	
	while dir_name != "":
		
		var level = get_level(levels_path + dir_name)
		
		if !level.empty(): 
			
			var button = _create_button(level)
			
			OfficialsList.add_child(button)
			var _er = (button.connect("pressed", self, "_level_selected", [button]))
			
		
		dir_name = directory.get_next()
		
	


func get_custom_levels(_err):
	
	var directory = Directory.new()
	var levels_path = "%s/%s" % [OS.get_user_data_dir(), GlobalLevelManager.LEVELS_FOLDER_NAME]
	
	if directory.open(levels_path) != OK: return
	
	directory.list_dir_begin()
	var dir_name = directory.get_next()
	
	while dir_name != "":
		
		var level = get_level(levels_path + dir_name)
		
		if !level.empty(): 
			
			var button = _create_button(level)
			
			CustomsList.add_child(button)
			button.connect("pressed", self, "_level_selected", [button])
		
		dir_name = directory.get_next()
		
	


func _create_button(level):
	var button = LevelButton.instance()
	button.level_info = level[0]
	button.level_data = level[1]
	button.song_data = level[2]
	button.text = level[0].get(GlobalConstants.KEY_LEVEL_NAME)
	return button


func get_level(dir):
	
	var list = []
	var level_info
	var level_data
	var song_data
	
	var level_directory = Directory.new()
	
	level_directory.open(dir)
	level_directory.list_dir_begin()
	
	var file_name = level_directory.get_next()
	var file = File.new()
	while file_name != "":
		
		var file_path = dir + file_name
		
		match file_name:
			GlobalConstants.FILE_NAME_LEVEL_INFO:
				
				file.open(file_path, File.READ)
				
				var info = parse_json(file.get_line())
				if info.error == OK:
					level_info = info.result
				
				file.close()
				
			GlobalConstants.FILE_NAME_SONG_DATA:
				
				var song = ResourceLoader.load(file_path)
				if song is AudioStreamSample or song is AudioStreamOGGVorbis:
					song_data = song
				
			GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM:
				var data = ResourceLoader.load(file_path)
				if data is Animation:
					level_data = data
				
			GlobalConstants.FILE_NAME_LEVEL_DATA_FILE:
				pass #To be implemented, maybe
		
		file_name = level_directory.get_next()
		
	
	level_directory.list_dir_end()
	
	if level_info and level_data and song_data:
		
		list = [level_info, level_data, song_data]
		
	
	return list
	


func _level_selected(level):
	
	if SelectedLevel == null:
		SelectedLevel = level
		set_Info(InfoCard1, level)
		InfoAnim.play("Begin")
		return
	
	if SelectedLevel.get_instance_id() != level.get_instance_id():
		
		if SelectedLevel.global_rect_position.y < level.global_rect_position.y:
			set_Info(InfoCard1, level)
			set_Info(InfoCard2, SelectedLevel)
			InfoAnim.play_backwards("SlideDown")
		else:
			set_Info(InfoCard2, level)
			set_Info(InfoCard1, SelectedLevel)
			InfoAnim.play("SlideDown")
		
		PreviewSong.stop()
		
		SelectedLevel = level
	
	PreviewSong = GlobalAudio.play_audio(SelectedLevel.song_data, true, 
	SelectedLevel.level_info.get(GlobalConstants.KEY_SONG_PREVIEW_OFFSET))
	


func set_Info(InfoCard, info):
	
	InfoCard.set_title(info.level_info.get(GlobalConstants.KEY_LEVEL_NAME))
	InfoCard.set_length(info.level_info.get(GlobalConstants.KEY_LEVEL_LENGTH))
	InfoCard.set_description(info.level_info.get(GlobalConstants.KEY_LEVEL_DESCRIPTION))
	#Image and Theme not yet implemented

