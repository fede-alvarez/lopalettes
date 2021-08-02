extends Control

onready var palette_container = $VBoxContainer/Palette
onready var palettes = $VBoxContainer/PalettesList
onready var author = $VBoxContainer/LblAuthor
onready var msg_popup = $MsgPopup

# Palettes list : https://lospec.com/palette-list/load?colorNumberFilterType=any&colorNumber=4&page=0&tag&sortingType=alphabetical
var url = "https://lospec.com/palette-list/"
var palettes_json = url + "load?colorNumberFilterType=any&colorNumber=4&page=0&tag&sortingType=alphabetical"
var current_palette
var color_palettes = []
var total_palettes = 0

var color = preload("res://entities/Color.tscn")
var win_size
var colors_count

func _ready():
	randomize()
	get_tree().get_root().set_transparent_background(true)
	
	$HTTPRequest.request(palettes_json)
	#$HTTPRequest.request(url + "winterfes-16.json")
	win_size = get_viewport().size

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	remove_colors()
	var json = JSON.parse(body.get_string_from_utf8())
	#print(json.result)
	#print(json.result.palettes[0].title)
	var palettes = json.result.palettes;
	total_palettes = palettes.size()
	
	for pal in palettes:
		color_palettes.append(pal)
		
	get_random_palette()

func get_random_palette():
	current_palette = color_palettes[randi() % total_palettes]
	
	for i in current_palette.colors.size():
		var palette_color = current_palette.colors[i]
		var new_color = color.instance()
		new_color.connect("color_selected", self, "on_color_selected")
		new_color.set_color("#"+palette_color)
		new_color.color = palette_color
		#new_color.rect_min_size = Vector2((win_size.x - 12)/colors_count,50)
		palette_container.add_child(new_color)
		
func get_colors():
	var json
	var colors
	if (!"error" in json.result):
		print(json.result)
		if json.result && json.result.colors != null:

			colors = json.result.colors
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
	else:
		print("Error")
		
func on_color_selected(color):
	OS.set_clipboard(color)
	$MsgPopup/LblColor.text = "Copied!\n"+color.to_upper()
	msg_popup.show()
	yield(get_tree().create_timer(1.5), "timeout")
	msg_popup.hide()
	
func remove_colors():
	for obj in palette_container.get_children():
		palette_container.remove_child(obj)

func _on_PalettesList_item_selected(index):
	var palette_name = palettes.get_item_text(index).to_lower()
	$HTTPRequest.request(url + palette_name + '.json')


func _on_RandomButton_pressed():
	remove_colors()
	get_random_palette()


func _on_PNGButton_pressed():
	#$HTTPRequest.request(url + current_palette.title + "-8x.png")
	OS.shell_open(url + current_palette.slug + "-8x.png")
	pass
