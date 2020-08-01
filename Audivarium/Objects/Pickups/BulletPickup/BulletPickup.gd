extends Area2D

export var bullet_path : String = ""
export var one_time_pickup : bool = true
export var drift_to_player : bool = false setget set_drift, is_drifting_to_player
export var acceleration : float = 350
onready var Anim = $AnimationPlayer

var bullet

func _ready():
	if bullet_path == "": 
		queue_free()
		return
	
	var b = load(bullet_path)
	
	if b == null: 
		queue_free()
		return
	
	bullet = b.instance()
	
	if not bullet is Bullet:
		queue_free()
		return
	
	var t = bullet.get_texture()
	if t is Texture:
		$Sprite.texture = t
	
	var _err = connect("body_entered",self,"_on_BulletPickup_body_entered")
	_err = Anim.connect("animation_finished",self,"_on_AnimationPlayer_animation_finished")
	set_physics_process(drift_to_player)
	

func _on_BulletPickup_body_entered(body):
	if body.is_in_group(GlobalConstants.GROUP_PLAYER) and bullet != null and bullet != PlayerGlobals.CurrentBullet:
		PlayerGlobals.change_bullet(bullet)
		if one_time_pickup:
			Anim.play("Pickup")


func _on_AnimationPlayer_animation_finished(_anim_name):
	monitoring = false
	monitorable = false
	hide()

func set_drift(new):
	drift_to_player = new
	set_physics_process(new)

func is_drifting_to_player():
	return drift_to_player

func _physics_process(delta):
	if !PlayerGlobals.current_player: return
	
	var r = (global_position.angle_to_point(PlayerGlobals.current_player.global_position))
	
	var direction = -Vector2(cos(r), sin(r))
	
	global_position += direction * acceleration * delta
	
