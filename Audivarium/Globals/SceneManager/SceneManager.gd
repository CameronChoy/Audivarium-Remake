extends Control

signal scene_transition_completed
var thread = null
var new_scene
var res
var can_change = false
var transitioning = false
var moving_scene = false
var scene_to_preload
var anim = 0
var transition_delay = 0
onready var SceneTransition = $SceneTransition
onready var SceneOut = $SceneOut
onready var SceneIn = $SceneIn
onready var ViewportOut = $SceneOut/Viewport
onready var ViewportIn = $SceneIn/Viewport
onready var OutPanel = $SceneOut/Panel
onready var InPanel = $SceneIn/Panel

var SIMULATED_DELAY_SEC = 1.0
enum TransitionType {
	OUTSLIDELEFT,
	OUTSLIDERIGHT,
	OUTSLIDEUP,
	INSLIDELEFT,
	INSLIDERIGHT,
	INOUTSLIDELEFT,
	INOUTSLIDERIGHT,
	INOUTSLIDEUP,
	INOUTSLIDEDOWN,
	INFALLZOOMINWARD,
	OUTZOOMINWARDFADE,
	OUTZOOMOUTWARDSPIN,
}

var Transitions = {
	TransitionType.OUTSLIDELEFT : "OutSlideLeft",
	TransitionType.OUTSLIDERIGHT : "OutSlideRight",
	TransitionType.OUTSLIDEUP : "OutSlideUp",
	TransitionType.INSLIDELEFT : "InSlideLeft",
	TransitionType.INSLIDERIGHT : "InSlideRight",
	TransitionType.INOUTSLIDELEFT : "InOutSlideLeft",
	TransitionType.INOUTSLIDERIGHT : "InOutSlideRight",
	TransitionType.INOUTSLIDEUP : "InOutSlideUp",
	TransitionType.INOUTSLIDEDOWN : "InOutSlideDown",
	TransitionType.INFALLZOOMINWARD : "InFallZoomInward",
	TransitionType.OUTZOOMINWARDFADE : "OutZoomInwardFade",
	TransitionType.OUTZOOMOUTWARDSPIN : "OutZoomOutwardSpin",
}


func _ready():
	hide()
	set_physics_process(false)
	reset()
	


func reset():
	
	rect_position = Vector2()
	
	SceneIn.rect_pivot_offset = Vector2()
	SceneIn.rect_scale = Vector2(1,1)
	SceneIn.rect_position = Vector2()
	SceneIn.rect_rotation = 0
	SceneIn.modulate = Color.white
	
	SceneOut.rect_pivot_offset = Vector2()
	SceneOut.rect_scale = Vector2(1,1)
	SceneOut.rect_position = Vector2()
	SceneOut.rect_rotation = 0
	SceneOut.modulate = Color.white
	

func _thread_load(path):
	var ril = ResourceLoader.load_interactive(path)
	assert(ril)
	#var total = ril.get_stage_count()
	var start_time = OS.get_ticks_msec()
	var delay = transition_delay * 1000
	
	res = null
	while true:
		
		var err = ril.poll()
		
		if err == ERR_FILE_EOF:
			res = ril.get_resource()
			
			delay -= OS.get_ticks_msec() - start_time
			if delay > 0:
				OS.delay_msec(delay)
				
			
			can_change = true
			
			break
			
		elif err != OK:
			
			print("There was an error loading")
			break
	
	transition_delay = 0
	return
	


func _thread_done(anim_name):
	
	if thread and thread.is_active():
		var _result = thread.wait_to_finish()
	assert(res)
	
	new_scene = res.instance()
	var current_scene = get_tree().current_scene
	
	get_tree().root.remove_child(current_scene)
	
	ViewportOut.add_child(current_scene)
	ViewportIn.add_child(new_scene)
	
	
	call_deferred("raise")
	show()
	transitioning = true
	SceneTransition.play(anim_name)
	
	OutPanel.self_modulate = (PlayerGlobals.get_PlayerColors()[0])
	InPanel.self_modulate = (PlayerGlobals.get_PlayerColors()[0])
	


func load_scene(path, transitionType : int = TransitionType.INFALLZOOMINWARD, immediately_transition : bool = true):
	if moving_scene: return
	scene_to_preload = path
	can_change = false
	
	thread = Thread.new()
	thread.start( self, "_thread_load", path)
	
	call_deferred("raise")
	
	if immediately_transition : change_scene_to_loaded(transitionType)
	


func change_to_preloaded(scene, transitionType : int = TransitionType.INFALLZOOMINWARD):
	if not scene is PackedScene or moving_scene: return
	res = scene
	can_change = true
	change_scene_to_loaded(transitionType)
	


func change_scene_to_loaded(transitionType : int):
	
	if transitioning: return
	
	var anim_name = Transitions.get(transitionType, TransitionType.INFALLZOOMINWARD)
	
	match transitionType:
		TransitionType.INSLIDELEFT, \
		TransitionType.INSLIDERIGHT, \
		TransitionType.INFALLZOOMINWARD:
			SceneIn.call_deferred("raise")
			
		_:
			SceneOut.call_deferred("raise")
			
	
	moving_scene = true
	anim = anim_name
	set_physics_process(true)


func set_next_transition_delay(seconds : float = 0):
	transition_delay = seconds


func _on_SceneTransition_animation_finished(_anim_name):
	hide()
	transitioning = false
	moving_scene = false
	call_deferred("reset")
#	rect_position = Vector2()
#	SceneIn.rect_position = Vector2()
#	SceneOut.rect_position = Vector2()
#	SceneIn.self_modulate.a = 1
#	SceneOut.self_modulate.a = 1
	
	for child in ViewportIn.get_children():
		ViewportIn.remove_child(child)
	for child in ViewportOut.get_children():
		ViewportOut.remove_child(child)
	
#	get_tree().current_scene.free()
#	get_tree().current_scene = null
	get_tree().root.add_child(new_scene)
	
	get_tree().current_scene = new_scene
	
	emit_signal("scene_transition_completed")
	

func _physics_process(_delta):
	if can_change:
		call_deferred("_thread_done", anim)
		set_physics_process(false)

