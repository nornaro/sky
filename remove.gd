extends Button


var selected = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed",_on_pressed)
	
func _on_pressed() -> void:
	var output:Array
	if !%Versions.get_selected_items().is_empty():
		selected = %Versions.get_selected_items()[0]
	var json = JSON.parse_string(Global.current_db[selected])
	var err = OS.execute(Global.soar_path, ["r", json.pkg_name+"#"+json.pkg_id, "-y","--json", "--no-color"], output)
	if err != 0 or output.size() == 0: return
