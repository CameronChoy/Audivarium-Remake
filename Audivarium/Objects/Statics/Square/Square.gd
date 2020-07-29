extends Static

func _ready():
	var _err = connect("body_entered",self,"_on_Square_body_entered")
	

func _on_Square_body_entered(body):
	if _check_player(body): return
