extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed",_on_pressed)


func _on_pressed() -> void:
	get_tree().call_group(name,"show")
