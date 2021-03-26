extends ColorRect

var color_string
signal color_selected

func set_color(color):
	color_string = color
	$LinkButton.hint_tooltip = color.to_upper()
	
func get_current_color():
	return color_string

func _on_LinkButton_pressed():
	emit_signal("color_selected", color_string)
