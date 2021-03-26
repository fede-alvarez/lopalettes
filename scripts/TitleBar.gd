extends Control

var following = false
var drag_start_position = Vector2()

func _on_TitleBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			drag_start_position = get_local_mouse_position()

func _process(delta):
	if following:
		OS.set_window_position(OS.window_position + get_global_mouse_position() - drag_start_position)

func _on_Button_pressed():
	get_tree().quit()
