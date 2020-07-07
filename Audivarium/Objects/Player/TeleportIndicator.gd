tool
extends Sprite

var shader_rotation = 0
onready var parent = get_parent()

func _ready():
	set_physics_process(false)
	hide()

func _process(_delta):
	material.set_shader_param("rotation",deg2rad(shader_rotation))
	

func _physics_process(_delta):
	
	var direction = (get_global_mouse_position() - parent.position)
	var distance = direction.length_squared()
	
	if distance > pow(parent.teleport_range,2):
		position = direction.normalized() * parent.teleport_range
	else:
		position = parent.get_local_mouse_position()
		
	global_position.x = clamp(global_position.x,0,OS.get_screen_size().x)

func begin_aiming():
	set_physics_process(true)
	show()

func stop_aiming():
	position = Vector2()
	set_physics_process(false)
	hide()
