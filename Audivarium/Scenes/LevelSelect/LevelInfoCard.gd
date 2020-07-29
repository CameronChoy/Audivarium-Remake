extends PanelContainer
signal button_pressed

var current_level

func set_title(new : String):
	$Control/Title.text = new

func set_length(new):
	$Control/Length.text = str(new)

func set_image(new):
	$Control/Image.texture = new

func set_description(new : String):
	$Control/ScrollContainer/Description.text = new

func set_theme(new):
	$Control.theme = new


func _on_Play_pressed():
	emit_signal("button_pressed")
