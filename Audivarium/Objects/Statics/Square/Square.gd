extends Static

var destroy = preload("res://Objects/Statics/Square/SquareDestroyParticles.tscn")
var d_sound = preload("res://Objects/Statics/destroy_01.wav")

func _init():
	destroy_effect = destroy
	destroy_audio = d_sound
	

func _ready():
	var _err = connect("body_entered",self,"_on_Square_body_entered")
	

func _on_Square_body_entered(body):
	if _check_player(body): return
