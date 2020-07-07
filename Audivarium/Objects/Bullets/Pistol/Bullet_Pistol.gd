extends Bullet


var direction = Vector2()
const scene_path_impact = "res://Objects/Bullets/Pistol/Bullet_Pistol_Impact.tscn"
const audio_path_fire = "res://Objects/Bullets/Pistol/pistol_fire.wav"
const audio_path_hit = ""
const texture_path_pickup = "res://Objects/Bullets/Pistol/Bullet.png"
var _audio_fire = preload(audio_path_fire)
var impact_particles = preload(scene_path_impact)
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
	
	if !body.is_in_group("Player"):
		if body.has_method("Damaged"):
			body.Damaged()
		#GlobalAudio.play_audio()
		destroy()
	

func destroy():
	GlobalEffects.add_effects_node(impact_particles.instance(),position)
	
	queue_free()
