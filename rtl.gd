extends RichTextLabel

func _ready() -> void:
	connect("meta_clicked",_on_description_meta_clicked)
	selection_enabled = true

func _on_description_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)

#func _gui_input(event):
	#if event is not InputEventMouseButton:
		#return
	#if event.button_index != MOUSE_BUTTON_LEFT or !event.pressed:
		#return
	#select_all()
