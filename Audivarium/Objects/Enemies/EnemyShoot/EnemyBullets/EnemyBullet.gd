extends Area2D

var velocity = 3500
var direction = Vector2() 
var impact_audio = preload("res://Objects/Bullets/Bullet_Impact_Normal.tres")
var impact_particles = preload("res://Objects/Bullets/Sniper/Bullet_Sniper_Impact.tscn")
var fire_audio = preload("res://Objects/Enemies/EnemyShoot/EnemyBullets/EnemyBulletFire.wav")
var parent

func _ready():
	if fire_audio:
		GlobalAudio.play_audio(fire_audio)

func setup(_parent, speed = 3500, col = Color.red):
	modulate = col
	velocity = speed
	parent = _parent
	direction = -Vector2(cos(rotation),sin(rotation))
	


func _process(delta):
	position += direction * velocity * delta


func _on_Area2D_area_entered(area):
	_object_enter(area)


func _on_Area2D_body_entered(body):
	_object_enter(body)


func _object_enter(body):
	if parent and body.get_instance_id() == parent.get_instance_id(): return
	if body.has_method("Damaged") and body.is_in_group(GlobalConstants.GROUP_DAMAGABLE):
		body.Damaged(self)
	if body.is_in_group(GlobalConstants.GROUP_BULLET_SOLID):
		if !body.is_in_group(GlobalConstants.GROUP_OUSTIDE_BOUNDARIES):
			GlobalAudio.play_audio(impact_audio)
		destroy()


func destroy():
	var particles = impact_particles.instance()
	particles.position = position
	particles.modulate = PlayerGlobals.ColorBullet
	GlobalEffects.add_child(particles)
	
	queue_free()
