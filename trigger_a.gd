extends Control

@onready var other:Control = $"../TriggerB"

func _ready() -> void:
	connect("mouse_entered",_on_mouse_entered)

func _on_mouse_entered() -> void:
	if not is_instance_valid(other):
		return
	get_tree().call_group("desc_hide","hide")
	other.size_flags_horizontal = SIZE_SHRINK_BEGIN
	size_flags_horizontal = SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	other.mouse_filter = Control.MOUSE_FILTER_STOP
