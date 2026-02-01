extends Button

func _ready() -> void:
	connect("pressed",_on_pressed)
	$CPY/AnimationPlayer.animation_finished.connect(hide)

func _on_pressed() -> void:
	$"../RTL".select_all()
	DisplayServer.clipboard_set($"../RTL".tooltip_text)
	DisplayServer.clipboard_set_primary($"../RTL".tooltip_text)
	$CPY.show()
	$CPY/AnimationPlayer.play("fade")
