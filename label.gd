extends Button

func _ready() -> void:
	connect("pressed",_on_pressed)
	$CPY/AnimationPlayer.animation_finished.connect(hide)

func _on_pressed() -> void:
	$CPY.show()
	$CPY/AnimationPlayer.play("fade")
