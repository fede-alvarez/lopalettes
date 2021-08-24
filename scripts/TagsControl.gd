extends Control

onready var tags_label := $LblTags
onready var text_background := $PanelTextBg
onready var input_text := $PanelTextBg/TxtTags

onready var clean_tags := $PanelTextBg/CleanTagsButton

var anim_speed := 0.1
var is_open := false

signal on_tags_changed

func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	text_background.visible = false
	
	tags_label.modulate = Color(1,1,1,0)
	text_background.modulate = Color(1,1,1,0)
	
func toggle():
	is_open = !is_open
	text_background.visible = false if !is_open else true
	mouse_filter = Control.MOUSE_FILTER_STOP if is_open else Control.MOUSE_FILTER_PASS
	
	var init_alpha := 0 if is_open else 1
	var final_alpha := 1 if is_open else 0
	
	$FadeTween.interpolate_property(tags_label, "modulate", Color(1,1,1,init_alpha), Color(1,1,1,final_alpha), anim_speed)
	$FadeTween.interpolate_property(text_background, "modulate", Color(1,1,1,init_alpha), Color(1,1,1,final_alpha), anim_speed)
	$FadeTween.start()

func _on_CleanTagsButton_pressed():
	input_text.text = ""
	clean_tags.visible = false

func _on_TxtTags_text_changed(new_text):
	var not_empty = input_text.text != ""
	clean_tags.visible = true if not_empty else false
	
	if not_empty:
		emit_signal("on_tags_changed", new_text)
	
