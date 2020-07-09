extends Node
onready var ShockwaveCanvas = $CanvasLayer/ShockwaveRect
onready var ShockwaveTween = $CanvasLayer/ShockwaveRect/ShockwaveTween
onready var MainCamera = $MainCamera

func _init():
	print("bruh")

func _ready():
	MainCamera.position = OS.get_screen_size()/2
	

func Spawn_Shockwave(global_pos : Vector2,time : float = 1):
	var screen_size = OS.get_screen_size()
	
	var center = Vector2(global_pos.x / screen_size.x, global_pos.y / screen_size.y)
	center.y = 1 - center.y
	ShockwaveCanvas.material.set_shader_param("active",true)
	ShockwaveCanvas.material.set_shader_param("center",center)
	
	(ShockwaveTween.interpolate_property(
		ShockwaveCanvas.material,
		"shader_param/time",
		-0.1,
		3,
		time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT))
	
	ShockwaveTween.start()

func _on_ShockwaveTween_tween_all_completed():
	ShockwaveCanvas.material.set_shader_param("active",false)
	ShockwaveCanvas.material.set_shader_param("time",-0.1)


func add_effects_node(node = null, pos : Vector2 = Vector2()):
	var new_node = node
	if new_node != null:
		new_node.position = pos
		add_child(new_node)



