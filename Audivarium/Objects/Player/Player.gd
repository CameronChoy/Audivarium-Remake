extends KinematicBody2D

const ANIM_DAMAGED = "Damaged"

export var max_health : int = 5
export var acceleration : float = 40
export var deceleration : float = 0.75
export var max_speed : float = 600
export var dash_speed : float = 1450
export var dash_time : float = 0.15
export var dash_trail_time = 0.3
export var dash_trail_thickness = 5
export var dash_trail_fade_time = 1.5
export var dash_reset_time : float = 0.75
export var teleport_range : float = 500
export var teleport_reset_time : float = 1
export var teleport_shockwave_time : float = 2
export var invincible : bool = false
export var fire_while_focused = true
export(AudioStream) var audio_damaged = preload("res://Objects/Player/PlayerAudio/player_hit_02.wav")
export(AudioStream) var audio_die = preload("res://Objects/Player/PlayerAudio/player_gameover.wav")


onready var left = false
onready var right = false
onready var up = false
onready var down = false
onready var dash = false
onready var hold_shoot = false
onready var can_dash = true
onready var can_teleport = true
onready var teleport_readying = false
onready var can_shoot = true
onready var current_health = 0
var velocity = Vector2()
var current_max_speed
var last_direction = Vector2.RIGHT

onready var Collider = $CollisionShape2D
onready var Body = $Body
onready var DefaultSprite = $Body/DefaultSprite
onready var DashTween = $DashTween
onready var TeleportIndicator = $TeleportIndicator
onready var BulletTree = $BulletTree
onready var EquipedBulletText = $Hud/EquipedBulletText
onready var Anim = $PlayerAnim
onready var HealthBarLeft = $Hud/HealthBarLeft
onready var HealthBarRight = $Hud/HealthBarRight
onready var EffectsTree = $PlayerEffectsTree/Node2D
onready var TrailPointOne = $Body/TrailPoint
onready var TrailPointTwo = $Body/TrailPoint2
var bullet
var sprite_body
signal player_died

func _ready():
	
	current_max_speed = max_speed
	DefaultSprite.self_modulate = PlayerGlobals.get_PlayerColors()[0]
	set_body_sprite(PlayerGlobals.PlayerSpriteBody)
	var _err
	
	_err = CrossHair.connect("dash_reset_completed",self,"dash_reset_completion_signal")
	
	_err = CrossHair.connect("teleport_reset_completed",self,"teleport_reset_completion_signal")
	
	_err = CrossHair.connect("bullet_reload_completed",self,"bullet_reload_completion_signal")
	
	_err = PlayerGlobals.connect("bullet_changed",self,"bullet_change_signal")
	
	_err = DashTween.connect("tween_all_completed",self,"_on_DashTween_tween_all_completed")
	
	if !audio_damaged:
		audio_damaged = load(PlayerGlobals.AudioPathPlayerHit)
	if !audio_die:
		audio_die = load(PlayerGlobals.AudioPathPlayerGameOver)
	
	bullet = PlayerGlobals.get_DefaultBullet().instance()
	EquipedBulletText.text = bullet.get_name()
	
	HealthBarLeft.value = 0
	HealthBarRight.value = 0
	HealthBarLeft.get("custom_styles/fg").border_color = PlayerGlobals.get_PlayerColors()[1]
	HealthBarLeft.get("custom_styles/fg").bg_color = PlayerGlobals.get_PlayerColors()[0]
	
	PlayerGlobals.current_player = self
	


func _physics_process(delta):
	
	var moving = false
	var direction = Vector2()
	if left:
		direction.x -= acceleration
		moving = true
	if right:
		direction.x += acceleration
		moving = true
	if up:
		direction.y -= acceleration
		moving = true
	if down:
		direction.y += acceleration
		moving = true
	
	if moving:
		last_direction = Vector2(-cos(Body.rotation),-sin(Body.rotation))
	
	if dash:
		if moving:
			velocity = direction.normalized() * dash_speed
		else:
			velocity = last_direction * dash_speed
	else:
		velocity += direction
		
		if !moving:
			velocity *= deceleration
		
		var vel_squared = velocity.length_squared()
		if vel_squared > current_max_speed * current_max_speed:
			velocity = (velocity / sqrt(vel_squared)) * current_max_speed
	
	velocity = move_and_slide(velocity)
	Body.rotation = lerp_angle(Body.rotation, position.angle_to_point(position + velocity * delta),0.2)
	
	if bullet.is_automatic() and hold_shoot and can_shoot:
		shoot()
	


func _input(event):
	
	if event.is_action_pressed("dash") and can_dash:
		_dash()
		return
		
	
	if event.is_action_pressed("left"):
		left = true
		return
	elif event.is_action_released("left"):
		left = false
		return
	
	if event.is_action_pressed("right"):
		right = true
		return
	elif event.is_action_released("right"):
		right = false
		return
	
	if event.is_action_pressed("up"):
		up = true
		return
	elif event.is_action_released("up"):
		up = false
		return
	
	if event.is_action_pressed("down"):
		down = true
		return
	elif event.is_action_released("down"):
		down = false
		return
	
	if can_teleport:
		if event.is_action_pressed("teleport"):
			teleport_readying = true
			TeleportIndicator.begin_aiming()
			return
		elif event.is_action_released("teleport") and teleport_readying:
			teleport()
			teleport_readying = false
			TeleportIndicator.stop_aiming()
			return
	
	
	if fire_while_focused:
		_check_shoot(event)
		return


func _unhandled_input(event):
	_check_shoot(event)


func _check_shoot(event):
	if event.is_action_pressed("shoot"):
		
		teleport_readying = false
		TeleportIndicator.stop_aiming()
		
		hold_shoot = true
		if can_shoot:
			shoot()
		
		return
	elif event.is_action_released("shoot"):
		hold_shoot = false


func teleport():
	position = TeleportIndicator.global_position
	can_teleport = false
	CrossHair.play_TeleportReset()
	GlobalEffects.Spawn_Shockwave(position,teleport_shockwave_time)
	GlobalAudio.Spawn_AudioMuffleEffect()
	


func _dash():
	dash = true
	can_dash = false
	DashTween.interpolate_property(self,"current_max_speed",dash_speed,max_speed,dash_time,Tween.TRANS_SINE,Tween.EASE_OUT)
	DashTween.start()
	
	GlobalEffects.create_trail(TrailPointOne, PlayerGlobals.PlayerColors[0], dash_trail_thickness, dash_trail_time, dash_trail_fade_time, 0.02, false)
	GlobalEffects.create_trail(TrailPointTwo, PlayerGlobals.PlayerColors[0], dash_trail_thickness, dash_trail_time, dash_trail_fade_time, 0.02, false)
	


func _on_DashTween_tween_all_completed():
	dash = false
	CrossHair.play_DashReset(1/dash_reset_time)
	


func dash_reset_completion_signal():
	can_dash = true


func teleport_reset_completion_signal():
	can_teleport = true


func Damaged(_culprit):
	if invincible: return
	
	current_health += 1
	var h = float(current_health) / max_health
	
	HealthBarLeft.value = h
	HealthBarRight.value = h
	
	#destroy culprit
	
	if h < 1:
		GlobalAudio.play_audio(audio_damaged)
		Anim.play(ANIM_DAMAGED)
	else:
		Die()
		
	


func Die():
	hide()
	Collider.set_deferred("disabled",true)
	set_process_input(false)
	set_process(false)
	set_physics_process(false)
	set_process_unhandled_input(false)
	
	GlobalAudio.play_audio(audio_die)
	
	GlobalEffects.shake(0.35,30,15)
	#spawn destruction effect
	
	emit_signal("player_died")


func shoot():
	
	var new_bullet = bullet.duplicate(8)
	new_bullet.rotation = get_global_mouse_position().angle_to_point(position)
	new_bullet.position = position
	new_bullet.setup()
	new_bullet.modulate = PlayerGlobals.get_ColorBullet()
	BulletTree.add_child(new_bullet)
	
	can_shoot = false
	CrossHair.play_BulletReload(PlayerGlobals.get_FireDelay())
	
	var reload_audio = bullet.get("reload_audio")
	if reload_audio:
		GlobalAudio.play_audio(reload_audio)
		
	


func clear_bullets():
	for _bullet in BulletTree.get_children():
		_bullet.free()


func bullet_change_signal():
	
	bullet = PlayerGlobals.get_CurrentBullet()
	EquipedBulletText.text = bullet.get_name()
	
	for x in EffectsTree.get_children():
		x.queue_free()
	
	var effect = bullet.get("effects_node")
	if effect:
		
		effect = effect.instance()
		effect.player = self
		EffectsTree.add_child(effect)
		
	


func bullet_reload_completion_signal():
	can_shoot = true


func set_body_sprite(new):
	if !new: new = PlayerGlobals.DefaultPlayerSpriteBody
	
	PlayerGlobals.PlayerSpriteBody = new
	
	if new is PackedScene: new = new.instance()
	if not new is PlayerBody: return
	
	if sprite_body:
		var prev = sprite_body
		prev.get_parent().remove_child(prev)
		prev.queue_free()
	
	Body.add_child(new)
	new.position = Vector2()
	sprite_body = new
	
	if sprite_body.has_method("get_sprites"):
		
		var sprites = sprite_body.get_sprites()
		var colors = PlayerGlobals.get_PlayerColors()
		var colors_size = colors.size()
		
		for i in range(sprites.size()):
			var j = i if i < colors_size else colors_size - 1
			sprites[i].self_modulate = colors[j]
		
	
	DefaultSprite.hide()
	


func set_body_modulate(index, color):
	if !sprite_body or sprite_body.get_sprites().size() <= index: return
	var sprite = sprite_body.sprites[index]
	
	if !sprite: return
	
	sprite.self_modulate = color
	
