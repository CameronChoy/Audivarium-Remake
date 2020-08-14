tool
extends Sprite
class_name PlayerBody

const SPRITE_NAMES = "_Sprite"
export(Array, Texture) var textures = Array() setget _textures_changed
var sprites = []

func _ready():
	_collect_sprites()
	


func set_colors(colors : Array):
	if colors.empty(): return
	for i in range(colors.size()):
		if !colors[i]: continue
		
		call_deferred("set_single_color",i,colors[i])#set_single_color(i, colors[i])
		
	

func set_single_color(index, color):
	if index >= sprites.size(): return
	
	sprites[index].self_modulate = color
	


func _collect_sprites():
	sprites = []
	sprites.append(self)
	for c in get_children():
		if c is Sprite and c.name.begins_with(SPRITE_NAMES):
			sprites.append(c)
		 


func _textures_changed(new : Array):
	if !Engine.editor_hint: return
	textures = new
	for c in get_children():
		if c.name.begins_with(SPRITE_NAMES):
			c.queue_free()
		
	
	if new.empty():
		textures = null
		return
	
	
	if new[0]:
		texture = new[0]
	
	if new.size() > 1:
		for i in range(1,new.size()):
			if !new[i]: continue
			var s = Sprite.new()
			add_child(s)
			s.set_owner(self)
			s.texture = new[i]
			s.name = SPRITE_NAMES
			
		
	_collect_sprites()


func get_sprites():
	return sprites

