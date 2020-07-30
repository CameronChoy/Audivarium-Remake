tool
extends Static
var t = 0
var c


func _ready():
	var _err = connect("body_entered",self,"_on_Laser_body_entered")

func _on_Laser_body_entered(body):
	if _check_player(body): return



