extends Camera2D

var sway_speed = 3.0
var sway_amount = 0.05
var wiggle_time
var time = 0.0
var pixel_sway = 0.0
var current_random_x
var current_random_y

func _ready():
	set_process(false)
	
	set_sway()
	new_random()
	pass

func _process(delta):
	time += delta
	if time >= wiggle_time:
		new_random()
		time = 0
	
	offset = offset.cubic_interpolate(
		Vector2(current_random_x,current_random_y),
		Vector2(0.25,0),
		Vector2(-0.25,0),
		wiggle_time / ((delta+0.0001) * 1000))
	
	pass

func set_sway(amount_per_second : float = 3, screen_percent_sway : float = 0.02):
	sway_speed = amount_per_second
	sway_amount = screen_percent_sway
	pixel_sway = OS.get_screen_size() * sway_amount
	wiggle_time = 1.0 / sway_speed
	

func new_random():
	current_random_x = rand_range(-pixel_sway.x,pixel_sway.x)
	current_random_y = rand_range(-pixel_sway.y,pixel_sway.y)
	
