extends Static
class_name Enemy

export(bool) var AI_active = true setget set_active, is_active
export(float) var acceleration = 350


func _init():
	bullet_solid = true
	destructable = true
	


func _ready():
	._ready()
	set_physics_process(AI_active)
	connect("body_entered",self,"_check_player")


func _physics_process(_delta):
	return


func is_active():
	return AI_active

func set_active(new : bool):
	AI_active = new
	set_physics_process(new)
	

