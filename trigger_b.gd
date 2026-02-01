extends Button

@onready var other:Control = $"../TriggerA"

func _ready() -> void:
	connect("mouse_entered",_on_mouse_entered)
	connect("pressed",_on_mouse_entered)

func _on_mouse_entered() -> void:
	if not is_instance_valid(other):
		return
	get_tree().call_group("desc_hide","show")
	size_flags_horizontal = SIZE_EXPAND_FILL
	other.size_flags_horizontal = SIZE_SHRINK_END
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	other.mouse_filter = Control.MOUSE_FILTER_STOP
