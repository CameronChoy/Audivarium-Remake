extends Area2D

export var bullet_path : String = ""
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
	

func _on_BulletPickup_body_entered(body):
	if body.is_in_group(GlobalConstants.GROUP_PLAYER) and bullet != null and bullet != PlayerGlobals.CurrentBullet:
		PlayerGlobals.change_bullet(bullet)
		Anim.play("Pickup")


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
