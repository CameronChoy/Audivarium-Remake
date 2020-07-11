extends Node2D

const MAX_ITERATIONS = 50
var objects = []
var current_objects = []
onready var level_time = 0
onready var Anim = $LevelAnim
onready var Title = $LevelTitle

func _ready():
	set_process(false)
	#setup_level()

func setup_level(name : String, level_objects : Array):
	objects = level_objects
	Title.text = name
	#sort objects by first track time
	if objects.size() < 2: return
	
	for i in range(objects.size()):
		
		var t1 = objects[i].get_spawn_time()
		
		for j in range(i,objects.size()):
			
			if objects[j].get_spawn_time() < t1:
				
				var temp = objects[i]
				objects[i] = objects[j]
				objects[j] = temp
				
			
		
	


func _step(delta):
	level_time += delta
	
	var iter = 0
	while iter < MAX_ITERATIONS:
		
		if objects[0].get_spawn_time() <= level_time:
			
			current_objects.append(objects[0])
			objects.remove(0)
			iter += 1
			
		else:
			prints("object check break",level_time)
			break
		
	
	var queued_free = []
	for obj in current_objects:
		obj.step(level_time)
		
		if obj.get_despawn_time() < level_time:
			obj.queue_free()
			queued_free.append(obj)
		
	for obj in queued_free:
		current_objects.call_deferred("erase",obj)
		
	
	


func _process(delta):
	_step(delta)
