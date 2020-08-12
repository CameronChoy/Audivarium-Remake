tool
extends Sprite
const SPRITE_NAMES = "_Sprite"
export(Array, Texture) var textures = Array() setget _textures_changed,get_textures
var sprites = []

func _ready():
	_get_sprites()


func set_colors(colors : Array):
	if colors.empty(): return
	
	for i in range(colors.size()):
		if i >= sprites.size(): return
		
		if !colors[i]: continue
		
		sprites[i].self_modulate = colors[i]
		
	


func _get_sprites():
	for c in get_children():
		if c is Sprite and c.name.begins_with(SPRITE_NAMES):
			sprites.append(c)
		 

func _textures_changed(new : Array):
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
			
		
	


func get_textures():
	return textures

