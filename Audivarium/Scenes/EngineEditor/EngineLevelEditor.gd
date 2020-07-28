tool
extends Node2D

var PlayerObject = preload("res://Objects/Player/Player.tscn")
var PlayerSpawnPoint
var Confirmation
var EditorUI
var Background
enum ButtonChoices {QUIT, TEST, EXPORT, OVERWRITE}
var current_button_choice
var build_complete = false
var can_overwrite = false


var Anim
var Scene
var Player
var player_spawn_pos = OS.window_size / 2
export(String) var level_name = "level"
export(String, MULTILINE) var description = ""
export(Color) var background_color = Color("3b3b3b")
export(String, FILE, GLOBAL, "*.ogg, *.wav") var song
export(String) var song_name = ""
#export(float) var song_offset = 0
export(String) var creator_name = ""
export(float) var preview_offset = 0
export(bool) var enable_test_confirmation = true
export(bool) var enable_quit_confirmation = true
export(NodePath) var animation_player
export(NodePath) var level_scene
export(NodePath) var spawn_point

var prev_bg = background_color
const LEVEL_ANIM_MAIN = "leveldata"


func _ready():
	
	build_complete = false
	can_overwrite = false
	
	prev_bg = background_color
	
	Confirmation = $editorinfo/Control/ConfirmationDialog
	EditorUI = $editorinfo
	Background = $BackgroundSimulator
	
	Anim = get_node(animation_player)
	Scene = get_node(level_scene)
	PlayerSpawnPoint = get_node(spawn_point)
	Player = PlayerObject.instance()
	
	#VisualServer.set_default_clear_color(background_color)
	
	if !assert_important_nodes(): 
		print("Error, missing important node:",
		"\nAnimationPlayer: ", Anim,
		"\nLevelScene: ", Scene,
		"\nPlayer: ", Player
		)
		return
	
	if !Engine.editor_hint:
		Player.global_position = PlayerSpawnPoint.global_position
		Scene.add_child_below_node(PlayerSpawnPoint, Player)
		set_physics_process(false)
	
	var _err = Anim.connect("animation_finished",self,"_on_AnimationPlayer_animation_finished")
	
	player_spawn_pos = Player.global_position
	
	build_complete = true
	


func _physics_process(_delta):
	if prev_bg != background_color:
		prev_bg = background_color
		Background.color = background_color


func _export_level():
	if !assert_important_nodes(): return
	
	var directory = Directory.new()
	
	
	directory.open(OS.get_user_data_dir())
	
	if !can_overwrite and directory.dir_exists(level_name):
		current_button_choice = ButtonChoices.OVERWRITE
		Confirmation.window_title = "Level name already exists. Overwrite?"
		Confirmation.show()
		return
	
	can_overwrite = false
	
	directory.make_dir(level_name)
	
	var file = File.new()
	
	var dir_path = "%s/%s" % [OS.get_user_data_dir(), level_name]
	var level_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_LEVEL_INFO]
	var level_data_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM]
	var song_data_path = "%s/%s" % [dir_path, GlobalConstants.FILE_NAME_SONG_DATA]
	
	file.open(level_path, File.WRITE)
	
	Scene.remove_child(Player)
	for child in Scene.get_children():
		child.set_owner(Scene)
	
	var level_data = PackedScene.new()
	if level_data.pack(Scene) != OK:
		print("Error packing level data, cannot export")
		Scene.add_child_below_node(PlayerSpawnPoint, Player)
		return
	if ResourceSaver.save(level_data_path, level_data, ResourceSaver.FLAG_BUNDLE_RESOURCES) != OK:
		print("Error saving level data, cannot export")
		Scene.add_child_below_node(PlayerSpawnPoint, Player)
		return
	
	print("Level data successfully saved")
	Scene.add_child_below_node(PlayerSpawnPoint, Player)
	
	var song_data = load(song)
	if not song_data is AudioStreamSample and not song_data is AudioStreamOGGVorbis:
		print("Error, song is not compatible, cannot export")
		return
	
	if ResourceSaver.save(song_data_path, song_data) != OK:
		print("Error saving song data, cannot export")
		return
	
	print("Song successfully saved")
	
	var level_info = {
		GlobalConstants.KEY_LEVEL_NAME : level_name,
		GlobalConstants.KEY_LEVEL_PATH : GlobalConstants.FILE_NAME_LEVEL_DATA_ANIM,
		GlobalConstants.KEY_LEVEL_LENGTH : Anim.get_animation(LEVEL_ANIM_MAIN).length,
		GlobalConstants.KEY_LEVEL_DESCRIPTION : description,
		GlobalConstants.KEY_LEVEL_SONG_NAME : song_name,
		GlobalConstants.KEY_LEVEL_SONG_PATH : GlobalConstants.FILE_NAME_SONG_DATA,
		GlobalConstants.KEY_LEVEL_SONG_OFFSET : 0,#song_offset, #Not needed
		GlobalConstants.KEY_LEVEL_TYPE : GlobalConstants.VAR_LEVEL_TYPE_ANIM,
		GlobalConstants.KEY_LEVEL_BG : background_color,
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
	if (Anim and Player and Scene 
		and PlayerSpawnPoint and Confirmation and EditorUI 
		and Background):
		
		return true
		
	else:
		print("Error, missing important node(s):",
		"\nAnimationPlayer: ", Anim,
		"\nLevelScene: ", Scene,
		"\nPlayer: ", Player,
		"\nSpawn Point: ", PlayerSpawnPoint,
		"\nBackground", Background,
		"\nConfirmation Window: ", Confirmation,
		"\nEditorUI: ", EditorUI
		)
		return false
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		EditorUI.visible = !EditorUI.visible

