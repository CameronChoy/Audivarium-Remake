extends Enemy

enum BulletType {
	LASER,
	BULLET
}

var d = preload("res://Objects/Enemies/EnemyDestroyParticles_02.tscn")
var selected_bullet

export(float) var rotation_lerp = 0.03
export(BulletType) var bullet_type = BulletType.LASER setget _set_bullet
export(float) var bullet_speed = 3500
export(float) var bullet_laser_fade_time = 1
export(float) var bullet_laser_width = 7
export(float) var max_distance = 750
export(float) var aim_time = 3
export(float) var aim_fade_time = 0.2 setget _set_aimFadeTime
export(float) var fire_delay_time = 0.75
export(float) var reload_time = 3
export(float) var max_line_render_dist = 2250
export(float) var laser_width = 10
export(Color) var laser_color = Color("64ff0000")

onready var FollowState = $StateFollow
onready var AimState = $StateAim
onready var FireState = $StateFire
onready var ReloadState = $StateReload
onready var GlobalTree = $GlobalTree
onready var Line = $GlobalTree/Line2D
onready var Ray = $RayCast2D
onready var Body = $Sprite
onready var LineTween = $Tween

var state
var direction = Vector2()

var bullet_sniper = preload("res://Objects/Enemies/EnemyShoot/EnemyBullets/ShooterBullet.tscn")

func _init():
	destroy_effect = d


func _ready():
	direction = -Vector2(cos(Body.rotation), sin(Body.rotation))
	state = FollowState
	enter_follow()
	var _err = connect("destroyed",self,"_on_destroyed")
	


func _process(delta):
	
	if !PlayerGlobals.current_player: return
	
	state = state.update(delta)


func enter_follow():
	Line.points = []
	Line.modulate.a = 1
	Line.default_color = laser_color
	Line.width = laser_width


func enter_aim():
	AimState.current_aim_time = 0


func enter_fire():
	FireState.current_fire_time = 0
	laser_fade()


func enter_reload():
	ReloadState.current_reload_time = 0


func rotate_to_player():
	Body.rotation = _lerp_angle(Body.rotation,global_position.angle_to_point(PlayerGlobals.current_player.global_position),rotation_lerp)
	direction = -Vector2(cos(Body.rotation), sin(Body.rotation))
	


func move_to_player():
	global_position += direction * acceleration *  get_process_delta_time()


func laser_aim(rotate : bool = true):
	if rotate:
		rotate_to_player()
	
	Ray.cast_to = direction * max_line_render_dist

	Ray.force_raycast_update()
	var pos = Ray.get_collision_point() if Ray.is_colliding() else Ray.cast_to + global_position
	
	Line.points = [global_position, pos]
	


func laser_fade():
	LineTween.stop_all()
	LineTween.interpolate_property(Line,"modulate:a",1,0,aim_fade_time)
	LineTween.start()


func _set_aimFadeTime(new):
	aim_fade_time = clamp(new, 0, fire_delay_time)


func _set_bullet(type):
	bullet_type = type
	
	match type:
		BulletType.BULLET, _:
			selected_bullet = bullet_sniper
	


func shoot():
	if bullet_type == BulletType.LASER:
		_laser_shoot()
		return
	
	var new_bullet = selected_bullet.instance()
	new_bullet.rotation = Body.rotation
	new_bullet.global_position = global_position
	new_bullet.setup(self, bullet_speed, modulate)
	GlobalTree.add_child(new_bullet)
	
	


func _laser_shoot():
	
	laser_aim(false)
	
	Line.default_color = modulate
	Line.width = bullet_laser_width
	LineTween.stop_all()
	LineTween.interpolate_property(Line,"modulate:a",1,0,bullet_laser_fade_time)
	LineTween.start()
	
	Ray.force_raycast_update()
	if Ray.is_colliding():
		var body = Ray.get_collider()
		if body.has_method("Damaged") and body.is_in_group(GlobalConstants.GROUP_DAMAGABLE):
			body.Damaged(null)
	


func _on_destroyed():
	Line.points = []
