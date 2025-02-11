extends CanvasLayer

onready var CrossHairSprite = $CrossHairSprite
onready var SpriteAnim = $CrossHairSprite/AnimationPlayer
onready var RadialProgressRight = $ProgressBars/RadialProgressRight
onready var RadialProgressLeft = $ProgressBars/RadialProgressLeft
onready var BarProgressRight = $ProgressBars/ProgressBarRight
onready var RRadialAnim = $RRadialAnimPlayer
onready var LRadialAnim = $LRadialAnimPlayer
onready var RBarAnim = $RBarAnimPlayer

export var inGame_Cursor : StreamTexture

const ANIM_DASHRESET = "DashReset"
const ANIM_DASHRESETFINAL = "DashResetFinal"
const ANIM_TELEPORTRESET = "TeleportReset"
const ANIM_TELEPORTRESETFINAL = "TeleportResetFinal"
const ANIM_BULLETRELOAD = "Reload"
signal dash_reset_completed
signal teleport_reset_completed
signal bullet_reload_completed
onready var mouse_can_escape = false

enum CrossHairFrame {
	ONE = 0,
	TWO = 1,
	THREE = 2,
	FOUR = 3,
}

func _ready():
	CrossHairSprite.frame = 1
	CrossHairSprite.self_modulate = PlayerGlobals.ColorCrossHair
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED if OS.window_fullscreen else 0)
	RadialProgressLeft.value = 0
	RadialProgressRight.value = 0
	BarProgressRight.value = 0

func hide_crosshair():
	CrossHairSprite.hide()

func show_crosshair():
	CrossHairSprite.show()

func _input(event):
	
#	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
#
#		if event.is_action_pressed("ui_cancel"):
#			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#			CrossHairSprite.set_process(false)
#			Input.set_custom_mouse_cursor(null)
#
#
	if !mouse_can_escape and event is InputEventMouseButton and Input.get_mouse_mode() != Input.MOUSE_MODE_CONFINED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED if OS.window_fullscreen else 0)
		Input.set_custom_mouse_cursor(inGame_Cursor)
		
	

func _notification(what):
	if what == NOTIFICATION_WM_FOCUS_OUT:
		CrossHairSprite.set_process(false)
	elif what == NOTIFICATION_WM_FOCUS_IN:
		CrossHairSprite.set_process(true)


func change_crosshair(_frame : int = 3):
	CrossHairSprite.new_frame = _frame
	
	if CrossHairSprite.frame < _frame:
		SpriteAnim.play("ClockwiseSpin")
	elif CrossHairSprite.frame > _frame:
		SpriteAnim.play_backwards("ClockwiseSpin")
	


func set_mouse_escape(new : bool):
	mouse_can_escape = new


func play_DashReset(length : float = 1):
	RadialProgressRight.self_modulate = PlayerGlobals.get_ColorDashResetProgress()
	RRadialAnim.playback_speed = length if length > 1 else 1/length
	RRadialAnim.play(ANIM_DASHRESET)


func play_TeleportReset(length : float = 1):
	RadialProgressLeft.self_modulate =  PlayerGlobals.get_ColorTeleportResetProgress()
	LRadialAnim.playback_speed = length if length > 1 else 1/length
	LRadialAnim.play(ANIM_TELEPORTRESET)


func play_BulletReload(length : float = PlayerGlobals.DefaultFireDelay):
	BarProgressRight.self_modulate = PlayerGlobals.get_ColorFireDelayProgress()
	RBarAnim.playback_speed = length if length > 1 else 1/length
	RBarAnim.play(ANIM_BULLETRELOAD)


func _on_RAnimPlayer_animation_finished(anim_name):
	RRadialAnim.playback_speed = 1
	
	match anim_name:
		
		ANIM_DASHRESET:
			RRadialAnim.play(ANIM_DASHRESETFINAL)
			emit_signal("dash_reset_completed")
		
	


func _on_LAnimPlayer_animation_finished(anim_name):
	LRadialAnim.playback_speed = 1
	
	match anim_name:
		
		ANIM_TELEPORTRESET:
			LRadialAnim.play(ANIM_TELEPORTRESETFINAL)
			emit_signal("teleport_reset_completed")
			


func _on_RBarAnimPlayer_animation_finished(anim_name):
	RBarAnim.playback_speed = 1
	
	match anim_name:
		
		ANIM_BULLETRELOAD:
			BarProgressRight.value = 0
			emit_signal("bullet_reload_completed")


func get_inGame_Cursor():
	return inGame_Cursor

