extends Bullet

var direction = Vector2()
const scene_path_impact = "res://Objects/Bullets/MachineGun/Bullet_MachinGun_Impact.tscn"
const audio_path_fire = "res://Objects/Bullets/MachineGun/machinegun_fire.wav"
const  audio_path_hit = ""
const texture_path_pickup = "res://Objects/Bullets/MachineGun/Bullet_Slim.png"
var _audio_fire = preload(audio_path_fire)
var impact_particles = preload(scene_path_impact)
var pickup_texture = preload(texture_path_pickup)

func _init():
	automatic = true
	delay = 0.075
	bullet_texture = pickup_texture
	bullet_name = "Machine Gun"

func _ready():
	audio_fire = _audio_fire
	GlobalAudio.play_audio(audio_fire,false)

func setup(speed : float = 1750, color : Color = Color.white, fire_audio : AudioStream = audio_fire):
	.setup(speed,color,fire_audio)
	direction = Vector2(cos(rotation),sin(rotation))

func _physics_process(delta):
	position += (direction * s) * delta


func _on_BulletPistol_body_entered(body):
	
	if !body.is_in_group(GlobalConstants.GROUP_PLAYER):
		if body.has_method("Damaged"):
			body.Damaged()
		#GlobalAudio.play_audio()
		destroy()
	

func destroy():
	var particles = impact_particles.instance()
	particles.position = position
	GlobalEffects.add_child(particles)
	
	queue_free()
