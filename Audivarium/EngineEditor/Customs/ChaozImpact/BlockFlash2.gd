extends Node2D
var objects = []
func _ready():
	for c in get_children():
		c.position.x += rand_range(-25,25)
		objects.append(c)

func flash_attack():
	var o = objects[rand_range(0,objects.size())]
	o.Effect_Fade_In_And_Flash(1.2, Color.red, 0.2)
	
	objects.erase(o)
