extends Line2D

var TrailTween
var fade_time = 1
var life_time = 10
var delay = 0.1
onready var time = 0
onready var delay_time = 0
var origin
var parent_follow
var prev_points

func _ready():
	TrailTween = Tween.new()
	add_child(TrailTween)
	var _err = TrailTween.connect("tween_all_completed",self,"queue_free")
	prev_points = [origin]
	if !parent_follow or !parent_follow.get("global_position"):
		set_process(false)

func _process(delta):
	
	if parent_follow:
		
		delay_time += delta
		if delay_time >= delay:
			prev_points.append(parent_follow.global_position)
			points = prev_points
			delay_time = 0
		
		time += delta
		if time >= life_time:
			parent_follow = null
		
	else:
#		prev_points.append(parent_follow.global_position)
#		points = prev_points
		(TrailTween.interpolate_property(
		self,"self_modulate:a",1,0,fade_time,
		Tween.TRANS_LINEAR,Tween.EASE_IN_OUT))
		
		TrailTween.start()
		set_process(false)
		
