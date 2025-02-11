extends Node

var audio_focus = preload("res://Globals/AudioPlayer/UI Audio/ui_05.wav")
var audio_unfocus = preload("res://Globals/AudioPlayer/UI Audio/ui_06.wav")
var audio_select = preload("res://Globals/AudioPlayer/UI Audio/ui_04.wav")

onready var MuffleTween = $MuffleTween
var MuffleFilter = preload("res://Globals/AudioPlayer/AudioMuffleEffect.tres")

func play_audio(
stream : AudioStream, 
queue_free : bool = true, 
seek : float = 0,
audio_bus : String = "Effects",
volume : float = 0, 
pitch : float = 1,
loop : bool = false):
	
	if stream == null : return
	
	var player = AudioStreamPlayer.new()
	
	player.stream = stream
	player.bus = audio_bus
	player.volume_db = volume
	player.pitch_scale = pitch
	add_child(player)
	player.play(seek)
	
	if queue_free:
		player.connect("finished",player,"queue_free")
	elif loop:
		player.connect("finished",player,"play",[seek])
	
	return player


func Spawn_AudioMuffleEffect(time : float = 1):
	
	AudioServer.add_bus_effect(0,MuffleFilter,0)
	
	MuffleTween.interpolate_property(
		MuffleFilter,
		"cutoff_hz",
		100,
		10000,
		time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	
	MuffleTween.start()
	



func _on_MuffleTween_tween_all_completed():
	AudioServer.remove_bus_effect(0,0)

