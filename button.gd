extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("toggled",_on_toggled)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%Details.show()
		%Description.hide()
		return
	%Details.hide()
	%Description.show()
	
