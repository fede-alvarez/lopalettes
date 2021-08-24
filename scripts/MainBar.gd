extends Panel
onready var tags_control = $HContainer/TagsControl
onready var options_menu = $OptionsMenu

var following := false
var drag_start_position := Vector2()

signal on_menu_pressed
signal on_random_pressed
signal on_filter_pressed
signal on_close_pressed
signal on_menu_option_selected
signal on_tags_changed

func _ready():
	tags_control.connect("on_tags_changed", self, "_on_Tags_changed")
	
	options_menu.add_item("Download PNG", 1)
	options_menu.add_separator()
	options_menu.add_item("Exit", 2)
	
func _on_MainBar_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			following = !following
			drag_start_position = get_local_mouse_position()

func _process(delta):
	if following:
		OS.set_window_position(OS.window_position + get_global_mouse_position() - drag_start_position)

func tags_control_toggle():
	tags_control.toggle()
	
func _on_Tags_changed(tags):
	emit_signal("on_tags_changed", tags)

func options_menu_toggle():
	options_menu.show_modal()
	
# Button actions
func _on_MenuButton_pressed():
	emit_signal("on_menu_pressed")

func _on_RandomButton_pressed():
	emit_signal("on_random_pressed")
	
func _on_FilterButton_pressed():
	emit_signal("on_filter_pressed")

func _on_CloseButton_pressed():
	emit_signal("on_close_pressed")

func _on_OptionsMenu_id_pressed(id):
	emit_signal("on_menu_option_selected", id)
