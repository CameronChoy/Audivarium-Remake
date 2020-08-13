extends Node

var current_player

#var ColorPlayerMain = Color.lightblue
var ColorBullet = Color.orange
var ColorCrossHair = Color.white
var ColorTeleportIndicator = Color.white
var ColorDashResetProgress = Color.white
var ColorTeleportResetProgress = Color.white
var ColorFireDelayProgress = Color.orange

var DefaultColor = Color.white
var DefaultPlayerColors = [DefaultColor,DefaultColor,DefaultColor]
var PlayerColors = DefaultPlayerColors



const ScenePathDefaultPlayerBody = "res://Objects/Player/PlayerBodies/PlayerBodies/PlayerBody_01.tscn"
var DefaultPlayerSpriteBody = preload(ScenePathDefaultPlayerBody)

var PlayerSpriteBody

const AudioPathPlayerHit = "res://Objects/Player/PlayerAudio/player_hit.wav"
const AudioPathPlayerGameOver = "res://Objects/Player/PlayerAudio/player_gameover.wav"


const ScenePathDefaultBullet = "res://Objects/Bullets/Pistol/Bullet_Pistol.tscn"
var DefaultBullet = preload(ScenePathDefaultBullet)
var DefaultFireDelay = 0.15

onready var CurrentBullet = DefaultBullet.instance()
var FireDelay = 0.15
signal bullet_changed

const BODY = "PlayerBody"
const COL_MAIN = "ColorPlayerMain"
const COL_BULLET = "ColorBullet"
const COL_CROSSHAIR = "ColorCrosshair"
const COL_DASH = "ColorDashReset"
const COL_TEL = "ColorTeleportReset"
const COL_TEL_IND = "ColorTeleportIndicator"
const COL_FIRE_DELAY = "ColorFireDelay"


func _ready():
	load_player_values()

func save_player_values():
	var colors = []
	
	for c in PlayerColors:
		colors.append(c.to_html(false))
	
	var values = {
		BODY : PlayerSpriteBody.get_path(),
		COL_MAIN : colors,
		COL_BULLET : ColorBullet.to_html(false),
		COL_CROSSHAIR : ColorCrossHair.to_html(false),
		COL_TEL_IND : ColorTeleportIndicator.to_html(false),
		COL_TEL : ColorTeleportResetProgress.to_html(false),
		COL_DASH : ColorDashResetProgress.to_html(false),
		COL_FIRE_DELAY : ColorFireDelayProgress.to_html(false)
	}
	
	var file_path = "%s/%s" % [OS.get_user_data_dir(), GlobalConstants.FILE_NAME_PLAYER_VALUES]
	var file = File.new()
	if file.open(file_path, File.WRITE) != OK: return
	file.store_string(to_json(values))
	file.close()
	


func load_player_values():
	
	var file_path = "%s/%s" % [OS.get_user_data_dir(), GlobalConstants.FILE_NAME_PLAYER_VALUES]
	var file = File.new()
	
	if file.open(file_path, File.READ) != OK: return
	
	var info  = JSON.parse(file.get_as_text())
	
	if info.error != OK: return
	
	info = info.result
	
	PlayerSpriteBody = info.get(BODY) if info.has(BODY) else DefaultPlayerSpriteBody
	PlayerColors = (info.get(COL_MAIN)) if info.has(COL_MAIN) else DefaultPlayerColors
	ColorBullet = Color(info.get(COL_BULLET)) if info.has(COL_BULLET) else DefaultColor
	ColorCrossHair = Color(info.get(COL_CROSSHAIR)) if info.has(COL_CROSSHAIR) else DefaultColor
	ColorTeleportIndicator = Color(info.get(COL_TEL_IND)) if info.has(COL_TEL_IND) else DefaultColor
	ColorTeleportResetProgress = Color(info.get(COL_TEL)) if info.has(COL_TEL) else DefaultColor
	ColorDashResetProgress = Color(info.get(COL_DASH)) if info.has(COL_DASH) else DefaultColor
	ColorFireDelayProgress = Color(info.get(COL_FIRE_DELAY)) if info.has(COL_FIRE_DELAY) else DefaultColor
	
	for i in range(PlayerColors.size()):
		PlayerColors[i] = Color(PlayerColors[i])
	
	if ResourceLoader.exists(PlayerSpriteBody):
		PlayerSpriteBody = load(PlayerSpriteBody)
	CrossHair.CrossHairSprite.self_modulate = ColorCrossHair


func change_bullet(new_bullet = DefaultBullet):
	if !new_bullet.has_method("get_delay"): return
	CurrentBullet = new_bullet
	FireDelay = new_bullet.get_delay()
	GlobalAudio.play_audio(new_bullet.pickup_audio)
	emit_signal("bullet_changed")
	


func get_PlayerColors():
	return PlayerColors

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
