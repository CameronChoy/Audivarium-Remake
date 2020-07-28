extends Node

func screen_shake(time : float, amount_per_second : float, amplitude : float):
	GlobalEffects.shake(time, amount_per_second, amplitude)

func shockwave(global_pos : Vector2,time : float = 1):
	GlobalEffects.Spawn_Shockwave(global_pos, time)
