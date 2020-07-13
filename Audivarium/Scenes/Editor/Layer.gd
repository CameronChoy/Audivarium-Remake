extends LineEdit
var prev_text

func set_prev_text(new : String):
	prev_text = new


func _on_Layer_text_entered(new_text):
	if new_text.empty():
		text = prev_text
	else:
		prev_text = new_text


func _on_Layer_focus_exited():
	deselect()
	if text.empty():
		text = prev_text
	else:
		prev_text = text
