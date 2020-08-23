tool
extends PanelContainer
signal button_pressed

var current_level

func set_title(new):
	if not new is String: return
	$Control/TitleScroll/CenterContainer/Title.text = new

func set_length(new):
	#if not new is float or not new is String: return
	$Control/Length.text = "Length:\n %s s" % [new]

func set_image(new):
	var texture = new
	
	if texture is Image:
		var imagetex = ImageTexture.new()
		imagetex.create_from_image(texture)
		texture = imagetex
	
	if not texture is Texture: return
	
	var sprite = $Control/Control2/Image
	
	if texture is ImageTexture:
		var size = texture.get_size()
		var ratio = size.x / size.y
		texture.set_size_override(Vector2(165 * ratio ,165))
	
	sprite.texture = texture
	


func set_song(new):
	if not new is String: return
	$Control/SongScroll/Song.text = "Song:\n %s" % [new]

func set_song_author(new):
	if not new is String: return
	$Control/SongAuthorScroll/SongAuthor.text = "Song Creator:\n %s" % [new]

func set_description(new):
	if not new is String: return
	$Control/DescriptionScroll/Description.text = new


func set_creator(new):
	if not new is String: return
	$Control/CreatorScroll/Creator.text = "Creator:\n %s" % [new]


func set_theme(new):
	if not new is Theme: return
	theme = new


func get_theme():
	return theme

func _get(property):
	if property == "theme":
		hide()
		show()


func _on_Play_pressed():
	emit_signal("button_pressed")
