extends Node2D

const LevelSelect = "res://Scenes/LevelSelect/LevelSelect.tscn"
const MAX_ITERATIONS = 50
var objects = []
var current_objects = []
onready var level_time = 0

var Title
var TitleTween
var TitleTimer
onready var Scene
onready var title_move_back = true


func _ready():
	set_process(false)
	
	Scene = $Scene
	TitleTween = $TitleTween
	TitleTimer = $TitleTween/Timer
	Title = $LevelTitle
	
	
	if GlobalLevelManager.loaded_level and GlobalLevelManager.loaded_level_info:
		yield(SceneManager, "scene_transition_completed")
		var level = GlobalLevelManager.loaded_level.instance()
		
		if GlobalLevelManager.loaded_level_info.get(GlobalConstants.KEY_LEVEL_TYPE) == GlobalConstants.VAR_LEVEL_TYPE_ANIM:
			Scene.add_child(level)
			
			if GlobalLevelManager.loaded_level_anim is AnimationPlayer and GlobalLevelManager.loaded_level_anim.has_animation(GlobalConstants.LEVEL_ANIM_NAME):
				GlobalLevelManager.loaded_level_anim.play(GlobalConstants.LEVEL_ANIM_NAME)
				var _err = GlobalLevelManager.loaded_level_anim.connect("animation_finished", self, "_on_level_completed")
			
		
		Title.text = GlobalLevelManager.loaded_level_info.get(GlobalConstants.KEY_LEVEL_NAME)
		
		TitleTween.interpolate_property(Title, "rect_position:x",Title.rect_position.x, 0, 1,Tween.TRANS_SINE,Tween.EASE_OUT)
		TitleTween.start()
		
	
	#setup_level()

func _on_level_completed(_anim):
	SceneManager.load_scene(LevelSelect, SceneManager.TransitionType.OUTZOOMINWARDFADE)


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
		
	


func _on_Timer_timeout():
	TitleTween.interpolate_property(Title, "rect_position:x",0, -Title.rect_size.x, 1,Tween.TRANS_SINE,Tween.EASE_IN)
	TitleTween.start()
