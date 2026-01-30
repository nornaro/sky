extends Button


var selected = 0

func _ready() -> void:
	connect("pressed",_on_pressed)
	
func _on_pressed() -> void:
	var output:Array
	if !%Versions.get_selected_items().is_empty():
		selected = %Versions.get_selected_items()[0]
	if Global.current_db.is_empty():
		return
	var json = JSON.parse_string(Global.current_db[selected])
	var err = OS.execute(Global.soar_path, ["r", json.pkg_name+"#"+json.pkg_id, "-y","--json", "--no-color"], output)
	if err != 0 or output[0].is_empty(): 
		push_error("ERROR: ",err," Removal failed");
		%InfoBar.text = "[color=red]Removal of "+json.pkg_name+"#"+json.pkg_id+" failed[/color]"
		return
	%InfoBar.text = "[color=black]"+JSON.parse_string(output[0]).message+"[/color]"
