extends Control

signal scene_transition_completed
var thread = null
var new_scene
var res
var can_change = false
var scene_to_preload
var anim = 0
onready var SceneTransition = $SceneTransition
onready var SceneOut = $SceneOut
onready var SceneIn = $SceneIn
onready var ViewportOut = $SceneOut/Viewport
onready var ViewportIn = $SceneIn/Viewport

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
	set_process(false)
	

func _thread_load(path):
	var ril = ResourceLoader.load_interactive(path)
	assert(ril)
	#var total = ril.get_stage_count()
	
	res = null
	while true:
		
		var err = ril.poll()
		
		if err == ERR_FILE_EOF:
			res = ril.get_resource()
			can_change = true
			
			break
			
		elif err != OK:
			print("There was an error loading")
			break
	
	return
	


func _thread_done(anim_name):
	
	assert(res)
	var resource = res
	
	
	new_scene = resource.instance()
	
	ViewportOut.add_child(get_tree().current_scene.duplicate())
	ViewportIn.add_child(new_scene.duplicate())
	
	
	call_deferred("raise")
	show()
	SceneTransition.play(anim_name)
	



func load_scene(path, transitionType : int = TransitionType.INFALLZOOMINWARD, immediately_transition : bool = true):
	scene_to_preload = path
	can_change = false
	
	thread = Thread.new()
	thread.start( self, "_thread_load", path)
	
	call_deferred("raise")
	
	if immediately_transition : change_scene_to_loaded(transitionType)
	


func change_scene_to_loaded(transitionType : int):
	var anim_name = Transitions.get(transitionType)
	
	match transitionType:
		TransitionType.INSLIDELEFT, \
		TransitionType.INSLIDERIGHT, \
		TransitionType.INFALLZOOMINWARD, \
		TransitionType.OUTZOOMINWARDFADE:
			SceneIn.call_deferred("raise")
		_:
			SceneOut.call_deferred("raise")
	
	anim = anim_name
	set_process(true)


func _on_SceneTransition_animation_finished(_anim_name):
	hide()
	rect_position = Vector2()
	SceneIn.rect_position = Vector2()
	SceneOut.rect_position = Vector2()
	SceneIn.self_modulate.a = 1
	SceneOut.self_modulate.a = 1
	
	for child in ViewportIn.get_children():
		child.queue_free()
	for child in ViewportOut.get_children():
		child.queue_free()
	
	get_tree().current_scene.free()
	get_tree().current_scene = null
	
	get_tree().root.add_child(new_scene)
	
	get_tree().current_scene = new_scene
	
	emit_signal("scene_transition_completed")
	

func _process(_delta):
	if can_change: 
		call_deferred("_thread_done", anim)
		set_process(false)
