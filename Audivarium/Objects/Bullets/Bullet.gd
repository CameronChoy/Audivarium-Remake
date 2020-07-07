extends Area2D
class_name Bullet
var s
var col
var audio_fire
var automatic = false
var delay = 0.15
var bullet_texture
var bullet_name

func setup(speed : float = s, color : Color = col, fire_audio : AudioStream = audio_fire):
	s = speed
	audio_fire = fire_audio
	col = color
	

func is_automatic():
	return automatic

func get_delay():
	return delay

func get_texture():
	return bullet_texture

func get_name():
	return bullet_name
