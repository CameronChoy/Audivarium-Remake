extends Line2D

const MAX_DISTANCE = 100000
var player = null
onready var Ray = $RayCast2D

func _ready():
	if !player: set_process(false)
	default_color = PlayerGlobals.ColorPlayerMain
	Ray.add_exception(player)

func _process(_delta):
	
	var direction = MAX_DISTANCE * (CrossHair.CrossHairSprite.global_position - global_position).normalized()
	Ray.cast_to = direction
	Ray.force_raycast_update()
	
	var pos = direction
	if Ray.is_colliding():
		pos = (Ray.get_collision_point() - global_position) * 10
	
	points = [Vector2(), pos]
	
