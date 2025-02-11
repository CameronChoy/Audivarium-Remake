extends Node2D

const LevelSelect = "res://Scenes/LevelSelect/LevelSelect.tscn"
const LevelEnd = "res://Scenes/LevelScene/LevelEnd.tscn"
const MAX_ITERATIONS = 50
var objects = []
var current_objects = []
onready var level_time = 0

var Title
var TitleTween
var TitleTimer
var Scene
onready var PauseMenu = $PauseScreen
onready var SettingsMenu = $SettingsMenu
onready var LevelProgress = $CanvasLayer/LevelProgressBar
onready var LevelProgressTween = $CanvasLayer/LevelProgressBar/Tween
onready var title_move_back = true
onready var exiting = false

func _ready():
	GlobalLevelManager.level_completed = false
	set_process(false)
	
	Scene = $Scene
	TitleTween = $TitleTween
	TitleTimer = $TitleTween/Timer
	Title = $LevelTitle
	PauseMenu.hide()
	
	if GlobalLevelManager.loaded_level and GlobalLevelManager.loaded_level_info:
		yield(SceneManager, "scene_transition_completed")
		var level = GlobalLevelManager.loaded_level.instance()
		
		if GlobalLevelManager.loaded_level_info.get(GlobalConstants.KEY_LEVEL_TYPE) == GlobalConstants.VAR_LEVEL_TYPE_ANIM:
			Scene.add_child(level)
			
			if GlobalLevelManager.loaded_level_anim is AnimationPlayer and GlobalLevelManager.loaded_level_anim.has_animation(GlobalConstants.LEVEL_ANIM_NAME):
				GlobalLevelManager.loaded_level_anim.play(GlobalConstants.LEVEL_ANIM_NAME)
				var _err = GlobalLevelManager.loaded_level_anim.connect("animation_finished", self, "_on_level_completed")
				
			
		Title.text = GlobalLevelManager.loaded_level_info.get(GlobalConstants.KEY_LEVEL_NAME)
		
		LevelProgress.get("custom_styles/fg").bg_color = PlayerGlobals.get_PlayerColors()[0]
		LevelProgressTween.interpolate_property(LevelProgress,"value",0,10, GlobalLevelManager.loaded_level_info.get(GlobalConstants.KEY_LEVEL_LENGTH))
		LevelProgressTween.start()
		
	
	var pos = -(Title.get("custom_fonts/font").get_string_size(Title.text)).x - 50
	Title.rect_global_position.x = pos
	
	TitleTween.interpolate_property(Title, "rect_position:x", pos, 25, 1, Tween.TRANS_SINE,Tween.EASE_OUT,1)
	TitleTween.start()
	
	if PlayerGlobals.current_player:
		PlayerGlobals.current_player.pause_mode = PAUSE_MODE_STOP
		var _err = PlayerGlobals.current_player.connect("player_died",self,"_on_level_failed")
	
	var _err = PauseMenu.Resume.connect("pressed",self,"toggle_pause")
	_err = PauseMenu.Quit.connect("pressed",self,"_exit_level")
	_err = PauseMenu.Settings.connect("pressed",self,"_enter_settings")
	_err = SettingsMenu.connect("exitting_settings",self,"_exit_settings")
	SettingsMenu.set_process_input(false)
	
	


func _on_level_completed(_anim):
	exiting = true
	GlobalLevelManager.loaded_level_anim.stop(false)
	GlobalLevelManager.level_completed = true
	SceneManager.set_next_transition_delay(1)
	SceneManager.load_scene(LevelEnd, SceneManager.TransitionType.OUTZOOMOUTWARDSPIN, CrossHair.CrossHairFrame.THREE)
	


func _on_level_failed():
	exiting = true
	GlobalLevelManager.loaded_level_anim.stop(false)
	GlobalLevelManager.level_completed = false
	SceneManager.set_next_transition_delay(1)
	SceneManager.load_scene(LevelEnd, SceneManager.TransitionType.OUTZOOMOUTWARDSPIN, CrossHair.CrossHairFrame.THREE)
	


func _exit_level():
	get_tree().paused = false
	exiting = true
	set_process(false)
	if GlobalLevelManager.loaded_level_anim is AnimationPlayer:
		GlobalLevelManager.loaded_level_anim.stop(false)
	SceneManager.load_scene(LevelSelect, SceneManager.TransitionType.INOUTSLIDEUP, CrossHair.CrossHairFrame.THREE)
	


func setup_level(name : String, level_objects : Array):
	objects = level_objects
	Title.text = name
	#sort objects by first track time
	if objects.size() < 2: return
	
	for i in range(objects.size()):
		
		var t1 = objects[i].get_spawn_time()
		
		for j in range(i,objects.size()):
			
			if objects[j].get_spawn_time() < t1:
				
				var temp = objects[i]
				objects[i] = objects[j]
				objects[j] = temp
				
			
		
	


func _step(delta):
	level_time += delta
	
	var iter = 0
	while iter < MAX_ITERATIONS:
		
		if objects[0].get_spawn_time() <= level_time:
			
			current_objects.append(objects[0])
			objects.remove(0)
			iter += 1
			
		else:
			prints("object check break",level_time)
			break
		
	
	var queued_free = []
	for obj in current_objects:
		obj.step(level_time)
		
		if obj.get_despawn_time() < level_time:
			obj.queue_free()
			queued_free.append(obj)
		
	for obj in queued_free:
		current_objects.call_deferred("erase",obj)
		
	
	


func _process(delta):
	_step(delta)


func _on_TitleTween_tween_all_completed():
	
	if title_move_back:
		title_move_back = false
		TitleTimer.start(1.25)
		
	else:
		Title.hide()
	


func _on_Timer_timeout():
	TitleTween.interpolate_property(Title, "rect_position:x",Title.rect_global_position.x, -Title.rect_size.x - 50, 1,Tween.TRANS_CUBIC,Tween.EASE_IN)
	TitleTween.start()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and !exiting:
		toggle_pause()
	


func toggle_pause():
	get_tree().paused = !get_tree().paused
	PauseMenu.toggle_visibility(get_tree().paused)


func _enter_settings():
	SettingsMenu.show()
	SettingsMenu.set_process_input(true)
	set_process_unhandled_input(false)
	PauseMenu.hide()


func _exit_settings():
	SettingsMenu.hide()
	SettingsMenu.set_process_input(false)
	PauseMenu.show()
	call_deferred("set_process_unhandled_input",true)
	

