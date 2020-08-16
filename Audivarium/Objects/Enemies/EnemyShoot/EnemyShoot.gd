extends Enemy
var d

export(float) var rotation_lerp = 0.03
export(float) var max_distance = 750
export(float) var aim_time = 3
export(float) var aim_fade_time = 0.2 setget _set_aimFadeTime
export(float) var fire_time = 0.75
export(float) var reload_time = 3
export(float) var max_line_render_dist = 2250
export(float) var laser_width = 10
export(Color) var laser_color = Color("64ff0000")

onready var FollowState = $StateFollow
onready var AimState = $StateAim
onready var FireState = $StateFire
onready var Line = $Node/Line2D
onready var Ray = $RayCast2D
onready var Body = $Sprite
onready var LineTween = $Tween

var state
var direction = Vector2()

func _init():
	destroy_effect = d


func _ready():
	direction = -Vector2(cos(Body.rotation), sin(Body.rotation))
	state = FollowState
	Line.default_color = laser_color
	Line.width = laser_width
	


func _process(delta):
	if !PlayerGlobals.current_player: return
	state = state.update(delta)


func enter_follow():
	pass


func enter_aim():
	AimState.current_aim_time = 0
	Ray.enabled = true


func enter_fire():
	Ray.enabled = false
	FireState.current_reload_time = 0
	laser_fade()


func rotate_to_player():
	Body.rotation = _lerp_angle(rotation,global_position.angle_to_point(PlayerGlobals.current_player.global_position),rotation_lerp)
	direction = -Vector2(cos(Body.rotation), sin(Body.rotation))


func move_to_player():
	global_position += direction * acceleration *  get_process_delta_time()


func laser_aim(rotate : bool = true):
	if rotate:
		rotate_to_player()
	
	var max_pos = direction * max_line_render_dist
	
	Ray.cast_to = max_pos
	
	var pos
	if Ray.is_colliding():
		pos = Ray.get_collision_point()
	else:
		pos = max_pos
	
	Line.points = [0, pos]
	


func laser_fade():
	LineTween.stop_all()
	LineTween.interpolate_property(Line,"modulate:a",1,0,aim_fade_time)
	LineTween.start()

func _set_aimFadeTime(new):
	aim_fade_time = clamp(new, 0, fire_time)
