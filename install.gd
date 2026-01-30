extends Button


var selected = 0

func _ready() -> void:
	connect("pressed",_on_pressed)
	
func _on_pressed() -> void:
	if Global.current_db.is_empty(): return
	var json = JSON.parse_string(Global.current_db[selected])
	var output:Array
	if !%Versions.get_selected_items().is_empty():
		selected = %Versions.get_selected_items()[0]
	output = ["Broken",OS.execute_with_pipe(Global.soar_path, ["i", json.pkg_name+"#"+json.pkg_id, "-y","-q", "--no-color", "--portable"],true)]
	while output[0].contains("Broken"):
		output = []
		OS.execute("bash", ["-c", "soar info --no-color | grep 7z"], output, true)
		%InfoBar.text = "[color=Darkorange]" + "Installing: " + json.pkg_name+"#"+json.pkg_id + "[/color]"
	%InfoBar.text = "[color=Darkgreen]" + "Installed: " + json.pkg_name+"#"+json.pkg_id + "[/color]"
