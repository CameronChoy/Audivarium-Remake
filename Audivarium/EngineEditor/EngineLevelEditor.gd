tool
extends Node2D

#var PlayerObject = preload("res://Objects/Player/Player.tscn")
var PlayerSpawnPoint
var Confirmation
var EditorUI
var Background
var InfoCard
enum ButtonChoices {QUIT, TEST, EXPORT, OVERWRITE, DUPLICATE}
var current_button_choice
var build_complete = false
var can_overwrite = false


var Anim
var Scene
var Player
var player_spawn_pos = OS.window_size / 2
export(String) var level_name = "level" setget set_LevelName
export(String, MULTILINE) var description = "" setget set_Description
export(Color) var background_color = Color("3b3b3b")
export(String, FILE, GLOBAL, "*.ogg, *.wav") var song_preview
export(String) var song_name = "" setget set_SongName
export(String) var song_author = "" setget set_SongAuthor
#export(float) var song_offset = 0
export(String) var creator_name = "" setget set_Creator
export(float) var preview_offset = 0

export(NodePath) var player_node
export(NodePath) var animation_player
export(NodePath) var background_node
export(NodePath) var level_scene
export(NodePath) var spawn_point

export(bool) var enable_test_confirmation = true
export(bool) var enable_quit_confirmation = true
var prev_bg = background_color
const LEVEL_ANIM_MAIN = "leveldata"
const CUSTOMS_PATH = "res://EngineEditor/Customs/"

func _ready():
	build_complete = false
	can_overwrite = false
	
	prev_bg = background_color
	
	Confirmation = $editorinfo/Control/ConfirmationDialog
	EditorUI = $editorinfo
	InfoCard = $InfoCard/Info
	Background = get_node(background_node)
	
	Anim = get_node(animation_player)
	Scene = get_node(level_scene)
	PlayerSpawnPoint = get_node(spawn_point)
	Player = get_node(player_node)
	
	#VisualServer.set_default_clear_color(background_color)
	
	if !assert_important_nodes(): return
	
	EditorUI.show()
	
	if !Engine.editor_hint:
		CrossHair.CrossHairSprite.frame = 3
		Scene.pause_mode = PAUSE_MODE_STOP
		EditorUI.pause_mode = PAUSE_MODE_PROCESS
		Player.pause_mode = PAUSE_MODE_PROCESS
		get_tree().paused = true
		Player.global_position = PlayerSpawnPoint.global_position
		#Scene.add_child_below_node(PlayerSpawnPoint, Player)
		player_spawn_pos = Player.global_position
		set_physics_process(false)
	
	var _err = Anim.connect("animation_finished",self,"_on_AnimationPlayer_animation_finished")
	
	PlayerSpawnPoint.hide()
	Player.fire_while_focused = false
	
	build_complete = true
	


func _physics_process(_delta):
	if prev_bg != background_color:
		prev_bg = background_color
		if !Background: Background = $BackgroundSimulator
		else: Background.color = background_color


func _export_level():
	if !assert_important_nodes(): return
	
	var directory = Directory.new()
	var levels_dir_path = "%s/%s" % [OS.get_user_data_dir(), GlobalConstants.LEVELS_FOLDER_NAME]
	var dir_path = "%s/%s" % [levels_dir_path, level_name]
	
	if !directory.dir_exists(levels_dir_path):
		directory.make_dir_recursive(levels_dir_path)
	
	
	directory.open(levels_dir_path)
	
	if !can_overwrite and directory.dir_exists(level_name):
		current_button_choice = ButtonChoices.OVERWRITE
		Confirmation.window_title = "Level name already exists. Overwrite?"
		Confirmation.show()
		return
	
	can_overwrite = false
	
	
	directory.make_dir(level_name)
	
	
	var level_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_LEVEL_INFO]
	var level_data_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM]
	var song_data_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_SONG_DATA]
	var theme_data_path = "%s/%s" %[dir_path, GlobalConstants.FILE_NAME_LEVEL_INFO_THEME]
	
	
	Player.global_position = player_spawn_pos
	Player.rotation = 0
	Player.fire_while_focused = true
	if Player.has_method("clear_bullets"): Player.clear_bullets()
	
	PlayerSpawnPoint.hide()
	set_all_owners(Scene)
	
	
	var level_data = PackedScene.new()
	if level_data.pack(Scene) != OK:
		print("Error packing level data, cannot finish export")
		return
	if ResourceSaver.save(level_data_path, level_data, ResourceSaver.FLAG_BUNDLE_RESOURCES) != OK:
		print("Error saving level data, cannot finish export")
		return
	
	print("Level data successfully saved")
	
	
	if !save_audio(song_preview, song_data_path):
		return
	
	
	if InfoCard.theme and ResourceSaver.save(theme_data_path, InfoCard.theme) != OK:
		print("Error saving theme data, cannot finish export")
		return
	
	
	var info_file = File.new()
	
	if info_file.open(level_path, File.WRITE) != OK:
		print("Error creating Level Info, cannot finish export")
		info_file.close()
		return
	
	var level_info = {
		GlobalConstants.KEY_LEVEL_NAME : level_name,
		GlobalConstants.KEY_LEVEL_PATH : GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM,
		GlobalConstants.KEY_LEVEL_LENGTH : Anim.get_animation(LEVEL_ANIM_MAIN).length,
		GlobalConstants.KEY_LEVEL_DESCRIPTION : description,
		GlobalConstants.KEY_LEVEL_SONG_NAME : song_name,
		GlobalConstants.KEY_LEVEL_SONG_CREATOR : song_author,
		GlobalConstants.KEY_LEVEL_SONG_PATH : GlobalConstants.FILE_NAME_SONG_DATA,
		GlobalConstants.KEY_SONG_PREVIEW_OFFSET : preview_offset,
		GlobalConstants.KEY_LEVEL_TYPE : GlobalConstants.VAR_LEVEL_TYPE_ANIM,
		GlobalConstants.KEY_LEVEL_BG : background_color,
		GlobalConstants.KEY_PLAYER_POS : player_spawn_pos,
		GlobalConstants.KEY_CREATOR : creator_name,
		GlobalConstants.KEY_LEVEL_INFO_THEME : GlobalConstants.FILE_NAME_LEVEL_INFO_THEME,
		GlobalConstants.KEY_LEVEL_SONG_OFFSET : 0 #Not needed
	}
	
	info_file.store_string(to_json(level_info))
	
	print("Level Info successfully saved")
	
	info_file.close()
	print("Export complete\n")
	


func save_audio(path, save_path):
	
	var audio_data
	
	if path.begins_with("res://"):
		audio_data = load(path)
	else:
		var wav_end = path.ends_with("wav")
		var ogg_end = path.ends_with("ogg")
		if wav_end or ogg_end:
			audio_data = load_audio_outside_res(path, wav_end)
			if !audio_data: 
				print("Audio file incompatible, cannot finish export")
				return false
		else:
			print("Audio path incompatible, cannot finish export")
			return false
		
	
	
	if not audio_data is AudioStreamSample and not audio_data is AudioStreamOGGVorbis:
		print("Error, audio is not compatible, cannot finish export")
		return false
	
	if ResourceSaver.save(save_path, audio_data) != OK:
		print("Error saving audio data, cannot finish export")
		return false
	
	print("Audio successfully saved")
	return true


#https://godotengine.org/qa/51848/%2317848-bypass-able-load-resources-from-any-folder-other-than
func load_audio_outside_res(path, is_wav):
	
	var stream
	
	var file = File.new()
	if !file.file_exists(path): 
		print("Error, no audio file found for %s, cannot finish export" % path)
		return stream
	
	if file.open(path, File.READ) != OK:
		print("Error opening audio file for %s, cannot finish export" % path)
		return stream
	
	
	
	if is_wav:
		stream = AudioStreamSample.new()
	else:
		stream = AudioStreamOGGVorbis.new()
		print(stream.data)
	
	
	var buffer = file.get_buffer(file.get_len())
	
#	for i in 200:
#		buffer.remove(buffer.size()-1)
#		buffer.remove(0)
	
#	for i in range(buffer.size()):
#		buffer[i] -= 128
	
	stream.data = buffer
	
	if is_wav:
		stream.format = AudioStreamSample.FORMAT_16_BITS
		stream.stereo = true
	
	file.close()
	
	return stream
	


#https://www.reddit.com/r/godot/comments/40cm3w/looping_through_all_children_and_subchildren_of_a/
func set_all_owners(node):
	for child in node.get_children():
		
		if child.get_child_count() > 0:
			set_all_owners(child)
		
		child.set_filename("")
		child.set_owner(Scene)
		
	


func _duplicate_scene():
	if !assert_important_nodes(): return
	
	var duplicate_name = _ensure_unique_duplicate_name(level_name + "_duplicate")
	if duplicate_name is int:
		print("Error opening: '", CUSTOMS_PATH, "'. Cannot duplicate.")
	
	var folder_path = "%s/%s" % [CUSTOMS_PATH, duplicate_name]
	var scene_path = "%s/%s.tscn" % [folder_path, duplicate_name]
	
	var directory = Directory.new()
	
	if directory.make_dir_recursive(folder_path) != OK:
		print("Error creating folder. Cannot duplicate.")
		return
	
	var scene = PackedScene.new()
	if scene.pack(get_tree().current_scene) != OK:
		print("Error packing scene. Cannot duplicate.")
		return
	
	
	if ResourceSaver.save(scene_path, scene, ResourceSaver.FLAG_BUNDLE_RESOURCES) != OK:
		print("Error saving scene. Cannot duplicate.")
		return
	
	print("Successfully duplicated scene")
	


func _ensure_unique_duplicate_name(name):
	var dir = Directory.new()
	if dir.open(CUSTOMS_PATH) != OK: return ("-1"+name)
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		
		if file_name == name:
			
			var new_name = name
			var new_end = name.substr(name.length() - 1)
			
			if new_end.is_valid_integer():
				var iter = 1
				var end = name.length() - iter
				
				while new_end.is_valid_integer():
					iter += 1
					
					end -= 1
					new_end = name.substr(end)
					
				
				new_name = name.substr(0, end + 1)
				var new_num = int(new_end) + 1
				return _ensure_unique_duplicate_name(new_name + str(new_num))
				
			
			return _ensure_unique_duplicate_name(name + "1")
		
		file_name = dir.get_next()
	
	return name
	


func _on_ConfirmationDialog_confirmed():
	
	match current_button_choice:
		ButtonChoices.QUIT:
			get_tree().quit()
		ButtonChoices.TEST:
			_test_level()
		ButtonChoices.EXPORT:
			_export_level()
		ButtonChoices.OVERWRITE:
			can_overwrite = true
			_export_level()
		ButtonChoices.DUPLICATE:
			_duplicate_scene()
		


func _on_TestButton_pressed():
	
	if enable_test_confirmation:
		current_button_choice = ButtonChoices.TEST
		Confirmation.window_title = "Test level?"
		Confirmation.dialog_text = ""
		Confirmation.show()
	else:
		_test_level()
	


func _on_ExportButton_button_down():
	if !build_complete: return
	current_button_choice = ButtonChoices.EXPORT
	
	current_button_choice = ButtonChoices.EXPORT
	Confirmation.window_title = "Export level?"
	Confirmation.dialog_text = ""
	Confirmation.show()
	


func _on_QuitButton_button_down():
	
	if enable_quit_confirmation:
		current_button_choice = ButtonChoices.QUIT
		Confirmation.window_title = "Exit? (Nothing will be lost)"
		Confirmation.dialog_text = ""
		Confirmation.show()
	else:
		get_tree().quit()
	

func _test_level():
	Player.fire_while_focused = true
	EditorUI.hide()
	get_tree().paused = false
	Anim.play(LEVEL_ANIM_MAIN)


func _on_AnimationPlayer_animation_finished(_anim_name):
	EditorUI.show()

func assert_important_nodes():
	if (Anim and Player and Scene 
		and PlayerSpawnPoint and Confirmation and EditorUI 
		and Background and InfoCard):
		
		return true
		
	else:
		print("Error, missing important node(s):",
		"\nAnimationPlayer: ", Anim,
		"\nLevelScene: ", Scene,
		"\nPlayer: ", Player,
		"\nSpawn Point: ", PlayerSpawnPoint,
		"\nBackground", Background,
		"\nConfirmation Window: ", Confirmation,
		"\nEditorUI: ", EditorUI,
		"\nInfo Card: ", InfoCard
		)
		return false
	

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		EditorUI.visible = !EditorUI.visible


func _on_DuplicateButton_pressed():
	current_button_choice = ButtonChoices.DUPLICATE
	Confirmation.window_title = "Duplicate this scene?"
	Confirmation.dialog_text = "It will be saved to " + CUSTOMS_PATH
	Confirmation.show()


func set_LevelName(new):
	level_name = new
	if !InfoCard: return
	InfoCard.set_title(new)

func set_Description(new):
	description = new
	if !InfoCard: return
	InfoCard.set_description(new)

func set_SongName(new):
	song_name = new
	if !InfoCard: return
	InfoCard.set_song(new)

func set_SongAuthor(new):
	song_author = new
	if !InfoCard: return
	InfoCard.set_song_author(new)

func set_Creator(new):
	creator_name = new
	if !InfoCard: return
	InfoCard.set_creator(new)

#	for name in Anim.get_animation_list():
#
#		var a = Anim.get_animation(name)
#
#		for track_num in a.get_track_count():
#
#			if a.track_get_type(track_num) == Animation.TYPE_AUDIO:
#
#				for track_key in a.track_get_key_count(track_num):
#
#					var track_stream = a.audio_track_get_key_stream(track_num, track_key)
#
#					if ProjectSettings.globalize_path(track_stream.resource_path) == ProjectSettings.globalize_path(song):
#						#track_stream.take_over_path(song_data_path)
#						pass
