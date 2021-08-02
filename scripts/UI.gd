extends Control

onready var palette_container = $VBoxContainer/Palette
onready var palettes = $VBoxContainer/PalettesList
onready var author = $VBoxContainer/LblAuthor
onready var msg_popup = $MsgPopup
onready var confirm_popup = $ConfirmationDialog

onready var randomButton = $TitleBar/Panel/RandomButton
onready var pngButton = $TitleBar/Panel/PNGButton

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
	win_size = get_viewport().size

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	remove_colors()
	var json = JSON.parse(body.get_string_from_utf8())
	
	if (!"error" in json.result):
		randomButton.disabled = false
		pngButton.disabled = false
		
		var palettes = json.result.palettes
		total_palettes = palettes.size()
		
		for pal in palettes:
			color_palettes.append(pal)
			
		get_random_palette()
	else:
		print("Error getting palettes lists!")

func get_random_palette():
	current_palette = color_palettes[randi() % total_palettes]
	
	if "user" in current_palette:
		author.text = "Author: " + current_palette.user.name
	else:
		author.text = "Author: Not specified"
		
	for i in current_palette.colors.size():
		var palette_color = current_palette.colors[i]
		var new_color = color.instance()
		new_color.connect("color_selected", self, "on_color_selected")
		new_color.set_color("#"+palette_color)
		new_color.color = palette_color
		palette_container.add_child(new_color)

func on_color_selected(color):
	OS.set_clipboard(color)
	$MsgPopup/LblColor.text = "Copied!\n"+color.to_upper()
	msg_popup.show()
	yield(get_tree().create_timer(1.5), "timeout")
	msg_popup.hide()
	
func remove_colors():
	for obj in palette_container.get_children():
		palette_container.remove_child(obj)

func _on_RandomButton_pressed():
	remove_colors()
	get_random_palette()

func _on_PNGButton_pressed():
	#$HTTPRequest.request(url + current_palette.title + "-8x.png")
	OS.shell_open(url + current_palette.slug + "-8x.png")
	pass
