extends AnimatedSprite

var new_frame

func _process(_delta):
	position = get_global_mouse_position()

func _change_frame():
	frame = new_frame

