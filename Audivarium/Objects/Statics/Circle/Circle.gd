tool
extends Static

var destroy = preload("res://Objects/Statics/Circle/CircleDestroyParticles.tscn")
var d_sound = preload("res://Objects/Statics/destroy_01.wav")

func _init():
	destroy_effect = destroy
	destroy_audio = d_sound

func _ready():
	var _err = connect("body_entered",self,"_body_enter")

func _body_enter(body):
	if _check_player(body): return
