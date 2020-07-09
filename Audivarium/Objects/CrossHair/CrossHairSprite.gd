extends Sprite
#onready var parent = get_parent()

func _process(_delta):
	position = get_global_mouse_position()
