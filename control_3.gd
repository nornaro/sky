extends ScrollContainer

#func _ready() -> void:
	#connect("mouse_entered",_on_mouse_entered)
	#connect("mouse_exited",_on_mouse_exited)
#
#func _on_mouse_entered() -> void:
	#get_tree().call_group("desc_hide","hide")
#
#func _on_mouse_exited() -> void:
	#get_tree().call_group("desc_hide","show")
	#follow_focus = false
	#follow_focus = true
