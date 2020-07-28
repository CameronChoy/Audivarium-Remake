tool
extends Node
onready var ShockwaveCanvas = $CanvasLayer/ShockwaveRect
onready var ShockwaveTween = $CanvasLayer/ShockwaveRect/ShockwaveTween
onready var FrontLayer = $CanvasLayer
onready var MainCamera = $MainCamera
onready var MainEnvironment = $WorldEnvironment
var Default_bg_Color = Color("232020")
var Default_env = preload("res://Globals/GlobalEffects/world_env.tres")
var Trail = preload("res://Globals/GlobalEffects/Trail.gd")
var ShockWaveMaterial = preload("res://Globals/GlobalEffects/ShockwaveMaterial.tres")

func _ready():
	MainCamera.position = OS.get_screen_size()/2
	if Engine.editor_hint:
		ShockwaveCanvas.material = null
		MainEnvironment.environment = null
	else:
		ShockwaveCanvas.material = ShockWaveMaterial
		MainEnvironment.environment = Default_env
		MainCamera.show()
	

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


func add_effects_node(node = null, pos : Vector2 = Vector2(), raise : bool = true):
	var new_node = node
	if new_node != null:
		new_node.position = pos
		if raise:
			FrontLayer.add_child(new_node)
		else:
			add_child(new_node)


func create_trail(parent : NodePath, color : Color = Color.white, width : float = 10, life_time : float = 10, fade_time : float = 1, delay : float = 0.1, raise : bool = true):
	var p = get_node(parent)
	
	if !p.get("global_position"): return
	var t = Trail.new()
	t.default_color = color
	t.width = width
	t.fade_time = fade_time
	t.life_time = life_time
	t.delay = delay
	t.parent_follow = p
	t.origin = p.global_position
	
	if raise:
		FrontLayer.add_child(t)
	else:
		add_child(t)
	


func shake(time : float, amount_per_second : float, amplitude : float):
	MainCamera.shake(time, amount_per_second, amplitude)
