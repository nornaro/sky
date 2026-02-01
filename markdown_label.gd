extends RichTextLabel

func _ready() -> void:
	if !FileAccess.file_exists("res://README.md"):
		return
	text = FileAccess.get_file_as_string("res://README.md")
