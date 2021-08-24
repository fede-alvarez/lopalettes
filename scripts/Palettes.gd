extends GridContainer

var color_component = preload("res://components/ColorComponent.tscn")

var rng = RandomNumberGenerator.new();
var palettes
var palettes_count := 0
var current_palette
var info_widget

signal on_requests_over

func _ready():
	rng.randomize()
	
func get_palette():
	if !palettes_count:
		return
	
	if info_widget == null:
		info_widget = (Globals.root_node).get_node("VContainer/AppInfoBg")
	
	current_palette = palettes[randi() % palettes.size()]
	
	if current_palette:
		var user_data = {"name": "- No user -"}
		var user_setted = false
		if "user" in current_palette:
			user_data = current_palette.user
			user_setted = true
			
		var palette = {"colors": current_palette.colors, "user": user_data, "title": current_palette.title, "slug": current_palette.slug}
		var info_msg = "Title: " + palette.title
		if user_setted:
			info_msg += " | Author: " + palette.user.name
		#print(palette)
		info_widget.show_message(info_msg)
		for color in palette.colors:
			var new_color = color_component.instance()
			new_color.set_color("#" + color)
			new_color.connect("color_selected", self, "_on_Color_selected")
			add_child(new_color)
		#print(palette)

func _on_Color_selected(color):
	#var palette = {"colors": current_palette.colors, "user": current_palette.user, "title": current_palette.title, "slug": current_palette.slug}
	#info_widget.show_message("Title: " + palette.title +  " | Author: " + palette.user.name)
	info_widget.show_timed_message("Color " + color + " copied to clipboard!")
	OS.set_clipboard(color)
	print(color)

func remove_colors():
	for color in get_children():
		#color.disconnect("color_selected", self)
		remove_child(color)
		
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if (json.result != null):
		emit_signal("on_requests_over")
		if (!"error" in json.result):
			palettes = json.result.palettes
			if palettes:
				remove_colors()
				palettes_count = palettes.size()
				get_palette()
	else:
		print(json.result)

func get_current_palette():
	return current_palette
