tool
extends Static

var destroy = preload("res://Objects/Statics/Circle/CircleDestroyParticles.tscn")

func _init():
	destroy_effect = destroy

func _ready():
	var _err = connect("body_entered",self,"_body_enter")

func _body_enter(body):
	if _check_player(body): return
