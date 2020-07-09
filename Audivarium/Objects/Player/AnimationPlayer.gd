
extends AnimationPlayer


func _ready():
	if has_animation("loop"):
		play("loop")

