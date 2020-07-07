extends Node

var ColorPlayerMain = Color.red
var ColorBullet = Color.blue
var ColorCrossHair = Color.white
var ColorTeleportIndicator = Color.white
var ColorDashResetProgress = Color.white
var ColorTeleportResetProgress = Color.white
var ColorFireDelayProgress = Color.purple

var DefaultColor = Color.white

const AudioPathPlayerHit = "res://Objects/Player/PlayerAudio/player_hit.wav"
const AudioPathPlayerGameOver = "res://Objects/Player/PlayerAudio/player_gameover.wav"


const ScenePathDefaultBullet = "res://Objects/Bullets/Pistol/Bullet_Pistol.tscn"
var DefaultBullet = preload(ScenePathDefaultBullet)
var DefaultFireDelay = 0.15

onready var CurrentBullet = DefaultBullet.instance()
var FireDelay = 0.15
signal bullet_changed

func set_player_values(values : Dictionary):
	pass

func change_bullet(new_bullet = DefaultBullet):
	if !new_bullet.has_method("get_delay"): return
	CurrentBullet = new_bullet
	FireDelay = new_bullet.get_delay()
	emit_signal("bullet_changed")
	

func get_ColorPlayerMain():
	return ColorPlayerMain

func get_ColorBullet():
	return ColorBullet

func get_ColorCrossHair():
	return ColorCrossHair

func get_ColorTeleportIndicator():
	return ColorTeleportIndicator

func get_ColorDashResetProgress():
	return ColorDashResetProgress

func get_ColorTeleportResetProgress():
	return ColorTeleportResetProgress

func get_ColorFireDelayProgress():
	return ColorFireDelayProgress

func get_AudioPathPlayerHit():
	return AudioPathPlayerHit

func get_AudioPathPlayerGameOver():
	return AudioPathPlayerGameOver

func get_FireDelay():
	return FireDelay

func get_CurrentBullet():
	return CurrentBullet


func get_DefaultColor():
	return DefaultColor

func get_DefaultFireDelay():
	return DefaultFireDelay

func get_DefaultBullet():
	return DefaultBullet
