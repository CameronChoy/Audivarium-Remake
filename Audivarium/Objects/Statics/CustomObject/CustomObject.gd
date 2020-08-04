tool
extends Static

export(String, MULTILINE) var warning = "This object cannot be properly used. So don't."
export(String, FILE, GLOBAL, "*.png, *.jpg") var texture
export(Shape2D) var collision_shape

onready var prev_tex = texture
onready var prev_col = collision_shape

func _ready():
	
	set_physics_process(Engine.editor_hint)
	
	$Sprite.texture = null
	if texture != "":
		var t = load(texture)
		if t is Texture:
			$Sprite.texture = t
	$CollisionShape2D.shape = collision_shape
	

func _physics_process(_delta):
	
	if texture != prev_tex and texture != "":
		var t = load(texture)
		if t is Texture:
			$Sprite.texture = t
			prev_tex = texture
	
	if prev_col != collision_shape:
		prev_col = collision_shape
		$CollisionShape2D.shape = collision_shape
	
