extends Panel

onready var info_label = $LblInfo
onready var msg_tween = $MsgTween

var prev_text

func _ready():
	msg_tween.interpolate_property(info_label, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1.5)
	prev_text = info_label.text

func show_message(message):
	info_label.text = message
	
func set_prev_text():
	info_label.text = prev_text

func show_timed_message(message):
	prev_text = info_label.text
	info_label.text = message
	msg_tween.interpolate_property(info_label, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1)
	msg_tween.start()
	yield(get_tree().create_timer(1), "timeout")
	msg_tween.interpolate_property(info_label, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1)
	msg_tween.start()
	yield(get_tree().create_timer(1), "timeout")
	info_label.text = prev_text
	msg_tween.interpolate_property(info_label, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1)
	msg_tween.start()
