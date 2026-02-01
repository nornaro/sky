extends Button

@onready var apps: ItemList = %Apps
@onready var versions: ItemList = %Versions
@onready var info_bar: RichTextLabel = %InfoBar

func _ready() -> void:
	connect("pressed",_on_pressed)
	#Global.soar_task_finished.connect(_on_soar_task_finished)
	
func _on_pressed() -> void:
	var _package:String = ""
	var output:Array
	if !apps.get_selected_items().is_empty():
		_package = apps.get_item_text(apps.get_selected_items()[0])
	if !versions.get_selected_items().is_empty():
		_package += "#" + versions.get_item_text(versions.get_selected_items()[0])
	var err = OS.execute(Global.soar_path, ["u", "-j", "--no-color"], output)
	if err != 0 or output.size() == 0:
		info_bar.text = "[color=red]Update failed! package[/color]"
		return
	var json = JSON.parse_string(output[0])
	info_bar.text = "[color=green]"+json.message+"[/color]"
