extends Particles2D

func _ready():
	emitting = true
	one_shot = true
	yield(get_tree().create_timer(lifetime),"timeout")
	queue_free()
