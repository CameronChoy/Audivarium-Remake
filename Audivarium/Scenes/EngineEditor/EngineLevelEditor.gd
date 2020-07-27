tool
extends Node2D

var PlayerObject = preload("res://Objects/Player/Player.tscn")
var PlayerSpawnPoint
onready var Confirmation = $editorinfo/Control/ConfirmationDialog
onready var EditorUI = $editorinfo
enum ButtonChoices {QUIT, TEST, EXPORT, OVERWRITE}
var current_button_choice
onready var build_complete = false
onready var can_overwrite = false

var Anim
var Scene
var Player
var player_spawn_pos = OS.window_size / 2
export(String) var info_level_name = "level"
export(String, MULTILINE) var info_description = ""
export(Color) var info_background_color = Color("3b3b3b")
export(String, FILE, GLOBAL, "*.ogg,*.wav") var song
export(String) var song_name = ""
export(float) var song_offset = 0
export(String) var creator_name = ""
export(float) var preview_offset = 0
export(bool) var enable_test_confirmation = true
export(bool) var enable_quit_confirmation = true

const LEVEL_ANIM_MAIN = "leveldata"


func _ready():
	Anim = $leveldata/AnimationPlayer
	Scene = $leveldata
	PlayerSpawnPoint = $leveldata/PlayerSpawnPoint
	Player = PlayerObject.instance()
	
	#VisualServer.set_default_clear_color(background_color)
	
	if !assert_important_nodes(): 
		print("Error, missing important node:",
		"\nAnimationPlayer: ", Anim,
		"\nLevelScene: ", Scene,
		"\nPlayer: ", Player
		)
		return
	
	Player.global_position = PlayerSpawnPoint.global_position
	Scene.add_child_below_node(PlayerSpawnPoint, Player)
	
	var _err = Anim.connect("animation_finished",self,"_on_AnimationPlayer_animation_finished")
	
	player_spawn_pos = Player.global_position
	
	build_complete = true
	


func _export_level():
	if !assert_important_nodes(): return
	
	var directory = Directory.new()
	
	
	directory.open(OS.get_user_data_dir())
	
	if !can_overwrite and directory.dir_exists(info_level_name):
		current_button_choice = ButtonChoices.OVERWRITE
		Confirmation.window_title = "Level name already exists. Overwrite?"
		Confirmation.show()
		return
	
	can_overwrite = false
	
	directory.make_dir(info_level_name)
	
	var file = File.new()
	
	var dir_path = "%s/%s" % [OS.get_user_data_dir(), info_level_name]
	var level_info_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_LEVEL_INFO]
	var level_data_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM]
	var song_data_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_SONG_DATA]
	
	file.open(level_info_path, File.WRITE)
	
	Scene.remove_child(Player)
	for child in Scene.get_children():
		child.set_owner(Scene)
	
	var level_data = PackedScene.new()
	if level_data.pack(Scene) != OK:
		print("Error packing level data, cannot export")
		Scene.add_child_below_node(PlayerSpawnPoint, Player)
		return
	if ResourceSaver.save(level_data_path, level_data) != OK:
		print("Error saving level data, cannot export")
		Scene.add_child_below_node(PlayerSpawnPoint, Player)
		return
	
	print("Level data successfully saved")
	Scene.add_child_below_node(PlayerSpawnPoint, Player)
	
	var song_data = load(song)
	if not song_data is AudioStreamSample:
		print("Error, song is not compatible, cannot export")
		return
	
	if ResourceSaver.save(song_data_path, song_data) != OK:
		print("Error saving song data, cannot export")
		return
	
	print("Song successfully saved")
	
	var level_info = {
		GlobalConstants.KEY_LEVEL_NAME : info_level_name,
		GlobalConstants.KEY_LEVEL_PATH : GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM,
		GlobalConstants.KEY_LEVEL_LENGTH : Anim.get_animation(LEVEL_ANIM_MAIN).length,
		GlobalConstants.KEY_LEVEL_DESCRIPTION : info_description,
		GlobalConstants.KEY_LEVEL_SONG_NAME : song_name,
		GlobalConstants.KEY_LEVEL_SONG_PATH : GlobalConstants.FILE_NAME_SONG_DATA,
		GlobalConstants.KEY_LEVEL_SONG_OFFSET : song_offset,
		GlobalConstants.KEY_LEVEL_TYPE : GlobalConstants.VAR_LEVEL_TYPE_ANIM,
		GlobalConstants.KEY_LEVEL_BG : info_background_color,
		GlobalConstants.KEY_PLAYER_POS : player_spawn_pos,
		GlobalConstants.KEY_CREATOR : creator_name,
		GlobalConstants.KEY_LEVEL_INFO_PALETTE : 0, #Not yet implemented
	}
	
	file.store_string(to_json(level_info))
	
	print("Level Info saved")
	
	file.close()
	print("Export complete\n")
	


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
	


func _on_TestButton_pressed():
	
	if enable_test_confirmation:
		current_button_choice = ButtonChoices.TEST
		Confirmation.window_title = "Test level?"
		Confirmation.show()
	else:
		_test_level()
	


func _on_ExportButton_button_down():
	if !build_complete: return
	current_button_choice = ButtonChoices.EXPORT
	
	current_button_choice = ButtonChoices.EXPORT
	Confirmation.window_title = "Export level?"
	Confirmation.show()
	


func _on_QuitButton_button_down():
	
	if enable_quit_confirmation:
		current_button_choice = ButtonChoices.QUIT
		Confirmation.window_title = "Exit? (Nothing will be lost)"
		Confirmation.show()
	else:
		get_tree().quit()
	

func _test_level():
	EditorUI.hide()
	Anim.play(LEVEL_ANIM_MAIN)


func _on_AnimationPlayer_animation_finished(_anim_name):
	EditorUI.show()

func assert_important_nodes():
	if (Anim and Player and Scene and PlayerSpawnPoint):
		return true
	else:
		print("Error, missing important node:",
		"\nAnimationPlayer: ", Anim,
		"\nLevelScene: ", Scene,
		"\nPlayer: ", Player,
		"\nSpawn Point: ", PlayerSpawnPoint
		)
		return false
	
