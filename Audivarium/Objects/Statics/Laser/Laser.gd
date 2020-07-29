tool
extends Static
onready var tween = $Tween
var t = 0
var c


func _ready():
	tween = $Tween
	var _err = connect("body_entered",self,"_on_Laser_body_entered")
	_err = tween.connect("tween_completed",self,"_on_Tween_tween_completed")


func _on_Laser_body_entered(body):
	if _check_player(body): return


func fade_in(time : float, end_alpha : float = 1):
	
	tween.interpolate_property(self,"modulate:a",0, end_alpha, time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func flash_attack(color : Color, time : float):
	
	tween.interpolate_property(self,"modulate",modulate, color, 0.05, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	t = time
	c = modulate
	monitoring = true
	monitorable = true
	tween.start()


func _on_Tween_tween_completed(_object, key):
	
	if key == ":modulate":
		monitoring = false
		monitorable = false
		tween.interpolate_property(self,"modulate:r",modulate.r, c.r, t, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(self,"modulate:g",modulate.g, c.g, t, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(self,"modulate:b",modulate.b, c.b, t, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(self,"modulate:a",1, 0, t, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		
	
