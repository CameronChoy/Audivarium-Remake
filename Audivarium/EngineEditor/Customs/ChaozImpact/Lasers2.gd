extends Node2D
onready var lasers = []
var temp_lasers = []

func _ready():
	random()
	for c in $Vertical.get_children():
		lasers.append(c)
	for c in $Horizontal.get_children():
		lasers.append(c)
	temp_lasers = lasers.duplicate(true)

func random():
	var pos = rand_range(15,75)
	for c in $Vertical.get_children():
		c.position.x = pos
		pos += rand_range(40,125)
	pos = rand_range(15,75)
	for c in $Horizontal.get_children():
		c.position.y = pos
		pos += rand_range(30,72)

func random_flash():
	if temp_lasers.empty():
		random()
		temp_lasers = lasers.duplicate(true)
	var laser = temp_lasers[rand_range(0,temp_lasers.size())]
	laser.Effect_Fade_In_And_Flash(1.25, Color.red, 0.3)
	temp_lasers.erase(laser)
# Effect_Fade_In_And_Flash(fade_in_time : float, flash_color : Color, flash_out_time : float, fade_out : bool = true):
