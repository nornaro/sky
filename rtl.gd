extends RichTextLabel

func _ready() -> void:
	connect("meta_clicked",_on_description_meta_clicked)

func _on_description_meta_clicked(meta: String) -> void:
	OS.shell_open(meta)
