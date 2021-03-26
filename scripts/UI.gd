extends Control

onready var palette_container = $VBoxContainer/Palette
onready var palettes = $VBoxContainer/PalettesList
onready var author = $VBoxContainer/LblAuthor
onready var msg_popup = $MsgPopup

var url = "http://nosvimosahi.com/api/lospec.php?name="
var color = preload("res://entities/Color.tscn")
var win_size
var colors_count

func _ready():
	get_tree().get_root().set_transparent_background(true)
	
	$HTTPRequest.request(url + "winterfes-16")
	win_size = get_viewport().size

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	remove_colors()
	var json = JSON.parse(body.get_string_from_utf8())
	var colors
	
	if json.result && json.result.palette != null:
		print(json.result)
		colors = json.result.palette
		author.text = "Author: " + json.result.author
		if colors:
			colors_count = colors.size()
			#print(colors_count)
			for i in colors_count:
				var palette_color = colors[i]
				var new_color = color.instance()
				new_color.connect("color_selected", self, "on_color_selected")
				new_color.set_color("#"+palette_color)
				new_color.color = palette_color
				#new_color.rect_min_size = Vector2((win_size.x - 12)/colors_count,50)
				palette_container.add_child(new_color)

func on_color_selected(color):
	OS.set_clipboard(color)
	$MsgPopup/LblColor.text = "Copied!\n"+color.to_upper()
	msg_popup.show()
	yield(get_tree().create_timer(2.0), "timeout")
	msg_popup.hide()
	
func remove_colors():
	for obj in palette_container.get_children():
		palette_container.remove_child(obj)

func _on_PalettesList_item_selected(index):
	var palette_name = palettes.get_item_text(index).to_lower()
	$HTTPRequest.request(url + palette_name)
