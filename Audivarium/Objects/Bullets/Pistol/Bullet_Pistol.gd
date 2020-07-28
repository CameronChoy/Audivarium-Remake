extends Bullet


var direction = Vector2()
const scene_path_impact = "res://Objects/Bullets/Pistol/Bullet_Pistol_Impact.tscn"
const audio_path_fire = "res://Objects/Bullets/Pistol/pistol_fire.wav"
const audio_path_hit = "res://Objects/Bullets/impact_01.wav"
const texture_path_pickup = "res://Objects/Bullets/Pistol/pistol_icon.png"

var _audio_fire = preload(audio_path_fire)
var impact_particles = preload(scene_path_impact)
var impact_audio = preload(audio_path_hit)
var pickup_texture = preload(texture_path_pickup)


func _init():
	bullet_texture = pickup_texture
	bullet_name = "Pistol"


func _ready():
	audio_fire = _audio_fire
	GlobalAudio.play_audio(audio_fire,false)


func setup(speed : float = 1750, color : Color = Color.white, fire_audio : AudioStream = audio_fire):
	.setup(speed,color,fire_audio)
	direction = Vector2(cos(rotation),sin(rotation))


func _physics_process(delta):
	position += (direction * s) * delta


func _on_BulletPistol_body_entered(body):
	_object_enter(body)


func destroy():
	var particles = impact_particles.instance()
	particles.modulate = PlayerGlobals.ColorBullet
	GlobalEffects.add_effects_node(particles, position)
	
	queue_free()
	


func _object_enter(body):
	if body.has_method("Damaged") and body.is_in_group(GlobalConstants.GROUP_DAMAGABLE):
		body.Damaged()
	if body.is_in_group(GlobalConstants.GROUP_BULLET_SOLID):
		GlobalAudio.play_audio(impact_audio)
		destroy()
	


func _on_BulletPistol_area_entered(area):
	_object_enter(area)
