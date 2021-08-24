extends Control

onready var palette_container = $VBoxContainer/Palette
onready var palettes = $VBoxContainer/PalettesList

# Messages
onready var loadingMsg = $VBoxContainer/LblMsg
onready var author = $VBoxContainer/LblAuthor

# Popups
onready var confirm_popup = $ConfirmationDialog
onready var filter_popup = $FilterPopup
onready var msg_popup = $MsgPopup

# Controls
onready var filterButton = $TitleBar/Panel/FilterButton
onready var randomButton = $TitleBar/Panel/RandomButton
onready var pngButton = $TitleBar/Panel/PNGButton

onready var tagsText = $TitleBar/Panel/TxtTags
onready var lblTags = $TitleBar/Panel/LblTags

# Palettes list : https://lospec.com/palette-list/load?colorNumberFilterType=any&colorNumber=4&page=0&tag&sortingType=alphabetical
var url = "https://lospec.com/palette-list/"
var filter_string = "load?colorNumberFilterType=any&colorNumber=8&page=0&tag=&sortingType=default"
var palettes_json = url + filter_string
var current_palette
var color_palettes = []
var total_palettes = 0

var lastcolor_file = "user://lastcolor.save"

var color = preload("res://entities/Color.tscn")
var win_size
var colors_count

var tag_filter_visible = false
var loaded_palette

func _ready():
	randomize()
	get_tree().get_root().set_transparent_background(true)
	loaded_palette = load_palette()
	#print("Loaded palette: ",loaded_palette)
	if loaded_palette:
		get_loaded_palette(loaded_palette)
	else:
		$HTTPRequest.request(palettes_json)
		
	win_size = get_viewport().size
	
	tagsText.visible = false
	lblTags.visible = false

func toggle_tags_search():
	tag_filter_visible = !tag_filter_visible
	
	if (tag_filter_visible):
		tagsText.visible = true
		lblTags.visible = true
	else:
		tagsText.text = 'type a tag...'
		remove_colors()
		make_request(palettes_json)
		tagsText.visible = false
		lblTags.visible = false
		
func make_request(url):
	loadingMsg.visible = true
	loadingMsg.text = "Loading palette..."
	$HTTPRequest.request(url)
	
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if (json.result != null):
		if (!"error" in json.result):
			remove_colors()

			author.visible = true
			loadingMsg.visible = false
			
			randomButton.disabled = false
			pngButton.disabled = false
			filterButton.disabled = false
			
			var palettes = json.result.palettes
			total_palettes = palettes.size()
			color_palettes.clear()
			for pal in palettes:
				color_palettes.append(pal)
				
			#print(color_palettes)
			if color_palettes.size() > 0:
				get_random_palette()
			else:
				loadingMsg.visible = true
				loadingMsg.text = "Not found"
		else:
			loadingMsg.visible = true
			loadingMsg.text = "Result error"
	else:
		loadingMsg.visible = true
		loadingMsg.text = "Error getting palettes lists!"
		
func get_loaded_palette(palette):
	total_palettes = 1
	color_palettes.clear()
	color_palettes.append(palette)
	
	loadingMsg.visible = false

	randomButton.disabled = false
	pngButton.disabled = false
	filterButton.disabled = false

	get_random_palette(true)
	
func get_random_palette(savedPalette = false):
	if (!savedPalette):
		current_palette = color_palettes[randi() % total_palettes]
		save_palette()
	else:
		current_palette = color_palettes[0]
		print("Current Palette")
		print(current_palette)
	
	if "user" in current_palette and "title" in current_palette:
		author.text = "Author: " + current_palette.user.name + " | Title: " + current_palette.title
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

func save_palette():
	var file = File.new()
	file.open(lastcolor_file, File.WRITE)
	file.store_var(current_palette, true)
	file.close()
	pass
	
func load_palette():
	var file = File.new()
	var content
	if file.file_exists(lastcolor_file):
		file.open(lastcolor_file, File.READ)
		content = file.get_var()
		file.close()
		
	return content

func _on_RandomButton_pressed():
	remove_colors()
	get_random_palette()

func _on_PNGButton_pressed():
	#$HTTPRequest.request(url + current_palette.title + "-8x.png")
	OS.shell_open(url + current_palette.slug + "-8x.png")
	pass

func _on_FilterButton_pressed():
	toggle_tags_search()

func _on_TxtTags_text_changed():
	$SearchTimer.start()

func _on_SearchTimer_timeout():
	print("Search")
	$SearchTimer.stop()
	loadingMsg.visible = true
	
	remove_colors()
	
	var tags_text = $TitleBar/Panel/TxtTags.text

	var new_filter_str
	if tags_text != "":
		tags_text = tags_text.replace(' ', '')
		new_filter_str = filter_string.replace('tag=', 'tag=' + tags_text)
		
	#print(url + new_filter_str)
	$HTTPRequest.request(url + new_filter_str)
