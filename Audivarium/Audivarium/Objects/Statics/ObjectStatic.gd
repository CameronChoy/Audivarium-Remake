extends Area2D
class_name Static

var bullet_solid = false
var destructable = false

func _ready():
	pass

func _update_scale_x(new : float):
	scale.x = new

func _update_scale_y(new : float):
	scale.y = new

func _update_scale(new : Vector2):
	scale = new

func _update_position_x(new : float):
	position.x = new

func _update_position_y(new : float):
	position.y = new

func _update_position(new : Vector2):
	position = new

func _bezier_update_position_x(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2, t : float):
	position.x = bezier(p1, p2, p3, p4, t).y

func _bezier_update_position_y(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2, t : float):
	position.y = bezier(p1, p2, p3, p4, t).y

func _update_rotation(new : float):
	rotation = new

func _update_rotation_degrees(new : float):
	rotation_degrees = new

func _set_color(new : Color):
	modulate = new

func _set_z_index(new : int):
	z_index = new

func is_bullet_solid():
	return bullet_solid

func is_destructable():
	return destructable

func bezier(p1 : Vector2, p2 : Vector2, p3 : Vector2, p4 : Vector2, t : float):
	var t_inverse = 1-t
	return (pow(t_inverse, 3) * p1) + \
			(3 * pow(t_inverse, 2) * t * p2) + \
			(3 * t_inverse * pow(t, 2) * p3) + \
			(pow(t, 3) * p4)
