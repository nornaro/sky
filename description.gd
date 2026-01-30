extends RichTextLabel


func _ready() -> void:
	# Connect the signal through code (ensure your RichTextLabel is named 'description')
	meta_clicked.connect(_on_description_meta_clicked)
	connect("mouse_entered",_on_mouse_entered)
	connect("mouse_exited",_on_mouse_exited)
	%Versions.item_selected.connect(_on_app_selected)


func _on_mouse_entered() -> void:
	get_tree().call_group("desc_hide","hide")

func _on_mouse_exited() -> void:
	get_tree().call_group("desc_hide","show")

# This function triggers whenever a [url] tag is clicked
func _on_description_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

var description_line:PackedScene = preload("res://description_line.tscn")
func _on_app_selected(app:String,index: int) -> void:
	var item = Global.soar_db[app]
	print(item.keys())
	return
	#print(item)
	for key:String in item.keys():
		var instance = description_line.instantiate()
		instance.name = Global.current_db[index]
		$"..".add_child(instance)
		instance.get_node("Label").text = key
		instance.get_node("RTL").text = str(item[key])
		#print()
		

func _on_app_selected_(index: int) -> void:
	var item = JSON.parse_string(Global.current_db[index])
	%WebJson.load_app_details(item.pkg_name,item.pkg_webpage)
	%WebJson._ready()
	bbcode_enabled = true
	var to_arr = func(val): 
		return JSON.parse_string(val) if typeof(val) == TYPE_STRING else val
	var txt = ""
	var header = "[b][color=cyan]%s[/color][/b][color=green]#%s[/color]:[color=yellow]%s[/color]" % [item.pkg_name, item.pkg_id, item.repo_name]
	
	txt += "▦ Name          │ " + header + "\n"
	txt += "────────────────┼──────────────────────────────────────────────────────────\n"

	# Content Rows
	txt += "✎ Description   │ " + str(item.description) + "\n"
	txt += "► Version       │ [color=cornflower_blue]" + str(item.version) + "[/color]\n"

	var size_mib = snapped(float(item.size) / (1024 * 1024), 0.01)
	txt += "■ Size          │ " + str(size_mib) + " MiB\n"
	txt += "⚿ Checksum      │ " + str(item.bsum) + " (blake3)\n"

	# Homepages with Blue Links
	var homes = to_arr.call(item.homepages)
	for i in range(homes.size()):
		var label = "⌂ Homepages     │ " if i == 0 else "                │ "
		txt += label + "[color=dodger_blue][url]" + homes[i] + "[/url][/color]\n"

	txt += "¶ Licenses      │ " + str(to_arr.call(item.licenses)).replace("[", "").replace("]", "").replace("\"", "") + "\n"

	# Notes
	var notes = to_arr.call(item.notes)
	for i in range(notes.size()):
		var label = "• Notes         │ " if i == 0 else "                │ "
		txt += label + notes[i] + "\n"
		
	# Technical Metadata
	txt += "▣ Type          │ [color=orchid]" + str(item.pkg_type) + "[/color]\n"
	txt += "⚒ Build CI      │ [color=dodger_blue][url]" + str(item.build_action) + "[/url][/color] (" + str(item.build_id) + ")\n"
	txt += "☀ Build Date    │ " + str(item.build_date) + "\n"
	txt += "✎ Build Log     │ [color=dodger_blue][url]" + str(item.build_log) + "[/url][/color]\n"
	txt += "✐ Build Script  │ [color=dodger_blue][url]" + str(item.build_script) + "[/url][/color]\n"
	txt += "➜ GHCR Blob     │ " + str(item.ghcr_blob) + "\n"
	txt += "▦ GHCR Package  │ [color=dodger_blue][url]" + str(item.ghcr_pkg) + "[/url][/color]\n"
	txt += "➤ Index         │ [color=dodger_blue][url]" + str(item.pkg_webpage) + "[/url][/color]"

	txt += "[/font_family]"
	text = txt
