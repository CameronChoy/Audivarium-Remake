extends Control

const OFFICIAL_LEVELS_PATH = "res://Scenes/Levels/OfficialLevels/"
const PREVIEW_SONG_MAX_DB = -6.0
const PREVIEW_SONG_MIN_DB = -50
const PREVIEW_FADE_TIME = 0.75

var LevelButton = preload("res://Scenes/Levels/LevelButton.tscn")
var LevelScene = preload("res://Scenes/LevelScene/LevelScene.tscn")

onready var FadeOut = $FadeOut
onready var FadeIn = $FadeIn
onready var InfoCard1 = $InfoCards/Info1
onready var InfoCard2 = $InfoCards/Info2
onready var InfoAnim = $InfoCards/InfoCardsAnim
onready var OfficialsList = $LevelsList/TabContainer/Levels/Scroll/OfficialsList
onready var CustomsList = $LevelsList/TabContainer/CustomLevels/Scroll/CustomsList

var SelectedLevel
var PreviewSong
var officials_thread
var customs_thread
onready var loaded_songs = []

func _ready():
	
	InfoCard1.connect("button_pressed",self,"InfoCard_selected",[InfoCard1])
	InfoCard2.connect("button_pressed",self,"InfoCard_selected",[InfoCard2])
	
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
	var index = 0
	while dir_name != "":
		
		var level = get_level(levels_path + dir_name)
		
		if !level.empty(): 
			
			var button = _create_button(level)
			button.index = index
			index += 1
			
			OfficialsList.add_child(button)
			var _er = (button.connect("pressed", self, "_level_selected", [button]))
			
		
		dir_name = directory.get_next()
		
	return officials_thread


func get_custom_levels(_err):
	
	var directory = Directory.new()
	var levels_path = "%s/%s" % [OS.get_user_data_dir(), GlobalConstants.LEVELS_FOLDER_NAME]
	
	if directory.open(levels_path) != OK: return
	
	directory.list_dir_begin()
	var dir_name = directory.get_next()
	var index = 0
	
	while dir_name != "":
		
		var level = get_level("%s/%s" % [levels_path, dir_name])
		
		if !level.empty(): 
			
			var button = _create_button(level)
			button.index = index
			index += 1
			
			CustomsList.add_child(button)
			button.connect("pressed", self, "_level_selected", [button])
			
		
		dir_name = directory.get_next()
		
	return customs_thread


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
		
		var file_path = "%s/%s" % [dir, file_name]
		
		match file_name:
			GlobalConstants.FILE_NAME_LEVEL_INFO:
				
				if file.open(file_path, File.READ) == OK:
					
					var info = JSON.parse(file.get_as_text())
					
					if info.error == OK:
						level_info = info.result
					
					file.close()
					
				
			GlobalConstants.FILE_NAME_SONG_DATA:
				
				song_data = file_path
				
			GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM:
				
				level_data = file_path
				
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
		fade_in()
		
	elif SelectedLevel.get_instance_id() != level.get_instance_id():
		
		if SelectedLevel.index < level.index:
			set_Info(InfoCard1, level)
			set_Info(InfoCard2, SelectedLevel)
			InfoAnim.play_backwards("SlideDown")
		else:
			set_Info(InfoCard2, level)
			set_Info(InfoCard1, SelectedLevel)
			InfoAnim.play("SlideDown")
		
		SelectedLevel = level
		
		fade_out()
		
	

#song file path
#Selected level index
#previous song
func fade_in():
	if FadeOut.is_active():
		yield(FadeOut,"tween_all_completed")
	
	var offset = SelectedLevel.level_info.get(GlobalConstants.KEY_SONG_PREVIEW_OFFSET)
	
	if PreviewSong:
		
		for s in loaded_songs:
			
			if s.index != SelectedLevel.index: continue
			
			PreviewSong.song.stream_paused = true
			PreviewSong = s
			s.song.stream_paused = false
			fade_in_interpolate()
			return
			
			
		
	
	var song = ResourceLoader.load(SelectedLevel.song_data)
	if song is AudioStreamSample or song is AudioStreamOGGVorbis:
		var new_preview = LoadedSong.new()
		new_preview.index = SelectedLevel.index
		new_preview.song = GlobalAudio.play_audio(song, true, offset if offset else 0, "Master", -50)
		print("fucking new")
		PreviewSong = new_preview
		loaded_songs.append(PreviewSong)
		
		fade_in_interpolate()
		
	


func fade_in_interpolate():
	#PreviewSong.song.playing = true
	FadeIn.interpolate_property(PreviewSong.song, "volume_db", -50, PREVIEW_SONG_MAX_DB, 1.25)
	FadeIn.start()


func fade_out():
	if FadeIn.is_active():
		yield(FadeIn,"tween_all_completed")
	FadeOut.interpolate_property(PreviewSong.song, "volume_db", PREVIEW_SONG_MAX_DB, -50, 1.25)
	FadeOut.start()
	


func set_Info(InfoCard, info):
	InfoCard.current_level = info
	InfoCard.set_title(info.level_info.get(GlobalConstants.KEY_LEVEL_NAME))
	InfoCard.set_length(info.level_info.get(GlobalConstants.KEY_LEVEL_LENGTH))
	InfoCard.set_description(info.level_info.get(GlobalConstants.KEY_LEVEL_DESCRIPTION))
	InfoCard.set_song(info.level_info.get(GlobalConstants.KEY_LEVEL_SONG_NAME))
	InfoCard.set_song_author((info.level_info.get(GlobalConstants.KEY_LEVEL_SONG_CREATOR)))
	#Image and Theme not yet implemented


func InfoCard_selected(Card):
	if Card.current_level:
		var level = ResourceLoader.load(SelectedLevel.level_data)
		if level:
			FadeIn.interpolate_property(PreviewSong.song, "volume_db", 0, -50, 1.25)
			FadeIn.start()
			GlobalLevelManager.loaded_level = level
			GlobalLevelManager.loaded_level_info = SelectedLevel.level_info
			SceneManager.change_to_preloaded(LevelScene, SceneManager.TransitionType.INFALLZOOMINWARD)


func _thread_completed(thread):
	var _err = thread.wait_to_finish()


func _exit_tree():
	if PreviewSong:
		PreviewSong.song.stop()
		
	


func _on_Button_pressed():
	var _err = OS.shell_open(str("file://", OS.get_user_data_dir()))

