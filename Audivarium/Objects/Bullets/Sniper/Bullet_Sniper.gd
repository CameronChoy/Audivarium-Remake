extends Bullet

var direction = Vector2()
const scene_path_impact = "res://Objects/Bullets/Pistol/Bullet_Pistol_Impact.tscn"
const audio_path_fire = "res://Objects/Bullets/Sniper/sniper_fire.wav"
const audio_path_hit = "res://Objects/Bullets/impact_01.wav"
const texture_path_pickup = "res://Objects/Bullets/Sniper/sniper_icon.png"

var _audio_fire = preload(audio_path_fire)
var impact_particles = preload(scene_path_impact)
var impact_audio = preload(audio_path_hit)
var pickup_texture = preload(texture_path_pickup)


func _init():
	delay = 1.2
	bullet_texture = pickup_texture
	bullet_name = "Sniper"


func _ready():
	audio_fire = _audio_fire
	GlobalAudio.play_audio(audio_fire,false)
	var trail_color = PlayerGlobals.ColorBullet
	trail_color.a = 0.4
	GlobalEffects.create_trail(self, trail_color, 3, 10, 0.6, true)


func setup(speed : float = 4200, color : Color = Color.purple, fire_audio : AudioStream = audio_fire):
	.setup(speed,color,fire_audio)
	direction = Vector2(cos(rotation),sin(rotation))


func _physics_process(delta):
	position += (direction * s) * delta


func destroy():
	var particles = impact_particles.instance()
	particles.modulate = PlayerGlobals.ColorBullet
	GlobalEffects.add_effects_node(particles, position)
	
	queue_free()
	


func _object_enter(body):
	if body.is_in_group(GlobalConstants.GROUP_BULLET_SOLID):
		if body.has_method("Damaged"):
			body.Damaged()
		GlobalAudio.play_audio(impact_audio)
		destroy()
	


func _on_BulletSniper_area_entered(area):
	_object_enter(area)


func _on_BulletSniper_body_entered(body):
	_object_enter(body)
