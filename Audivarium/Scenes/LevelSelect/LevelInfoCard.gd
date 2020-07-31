extends PanelContainer
signal button_pressed

var current_level

func set_title(new):
	if not new is String: return
	$Control/TitleScroll/CenterContainer/Title.text = new

func set_length(new):
	if not new is float or not new is String: return
	$Control/Length.text = "Length: %s" % [new]

func set_image(new):
	$Control/Image.texture = new

func set_song(new):
	if not new is String: return
	$Control/SongScroll/Song.text = "Song: %s" % [new]

func set_song_author(new):
	if not new is String: return
	$Control/SongAuthorScroll/SongAuthor.text = "Song Creator: %s" % [new]

func set_description(new):
	if not new is String: return
	$Control/DescriptionScroll/Description.text = new

func set_theme(new):
	if not new is Theme: return
	$Control.theme = new


func _on_Play_pressed():
	emit_signal("button_pressed")
