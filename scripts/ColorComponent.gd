extends TextureButton

var color_string
signal color_selected

func set_color(color):
	color_string = color
	modulate = Color(color)
	hint_tooltip = color.to_upper()

func get_current_color():
	return color_string

func _on_ColorComponent_pressed():
	emit_signal("color_selected", color_string)


func _on_ColorComponent_mouse_entered():
	$Animator.play("Selected")


func _on_ColorComponent_mouse_exited():
	$Animator.play_backwards("Selected")
