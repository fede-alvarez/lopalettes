extends Control

onready var app_info_widget := $VContainer/AppInfoBg
onready var palette_grid := $VContainer/PaletteGrid
onready var main_bar := $VContainer/MainBar
onready var http_request := $HTTPRequest
onready var exit_dialog := $ExitDialog
onready var loader := $PopupLoader

var is_loading := false
var current_tags

func _ready():
	Globals.root_node = self
	
	# Transparent window background
	get_tree().get_root().set_transparent_background(true)
	
	# Signals from main tool bar
	main_bar.connect("on_menu_pressed", self, "_on_Menu_pressed")
	main_bar.connect("on_random_pressed", self, "_on_Random_pressed")
	main_bar.connect("on_filter_pressed", self, "_on_Filter_pressed")
	main_bar.connect("on_close_pressed", self, "_on_Close_pressed")
	main_bar.connect("on_tags_changed", self, "_on_Tags_changed")
	main_bar.connect("on_menu_option_selected", self, "_on_Menu_Option_selected")
	# Starts and do requests
	make_request()

func make_request(alt_url = ""):
	app_info_widget.show_message("Loading...")
	is_loading = true
	loader.show_modal()
	palette_grid.connect("on_requests_over", self, "_on_Request_over")
	http_request.request(Globals.DEFAULT_URL if !alt_url else alt_url)

func _on_Request_over():
	palette_grid.disconnect("on_requests_over", self, "_on_Request_over")
	is_loading = false
	loader.hide()

func _on_Menu_pressed():
	#print("Menu pressed!")
	main_bar.options_menu_toggle()
	
func _on_Menu_Option_selected(id):
	match id:
		1:
			open_png_palette()
		2:
			exit_dialog.show_modal()

func open_png_palette():
	var palette = palette_grid.get_current_palette()
	if palette:
		OS.shell_open(Globals.LOSPEC_URL + palette.slug + "-8x.png")
	
func _on_Random_pressed():
	#print("Random pressed!")
	make_request()
	
func _on_Filter_pressed():
	#print("Filter pressed!")
	main_bar.tags_control_toggle()

func _on_Close_pressed():
	exit_dialog.show_modal()

func _on_ExitDialog_confirmed():
	get_tree().quit()

func _on_Tags_changed(tags):
	current_tags = tags
	$RequestTimer.start()
	
func _on_RequestTimer_timeout():
	var filtered_str
	if current_tags != "":
		current_tags = current_tags.replace(' ', '')
		filtered_str = Globals.QUERY_STRING.replace('tag=', 'tag=' + current_tags)
		
	if filtered_str:
		#print(Globals.LOSPEC_URL + filtered_str)
		make_request(Globals.LOSPEC_URL + filtered_str)
