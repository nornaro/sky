extends Node

var metadata_db = {}
@onready var apps:ItemList = %Apps
@onready var versions:ItemList = %Versions
@onready var description:RichTextLabel = %Description

func _ready() -> void:
	if !check_appstreamcli():
		push_error("appstreamcli not found.")
		return
	
	parse_soar_json()
	#load_fallback()
	#get_installed()
	
	#if Global.soar_db.is_empty():
		#load_fallback()
	for app in Global.soar_db.keys():
		apps.add_item(app)
		if !Global.installed.has(app):
			continue
		apps.set_item_custom_bg_color(apps.item_count-1,Color.DARK_SLATE_GRAY)

func parse_soar_json() -> void:
	var output = []
	var err = OS.execute(Global.soar_path , ["info", "-j", "--no-color"], output)
	print(output)
	var lines = output[0].split("\n")
	print(output)
	if err: 
		push_error("ERROR: ",err, " Loading fallback soar.json")
		lines = FileAccess.get_file_as_string("res://soar.json").split("\n")
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed == "" or !trimmed.begins_with("{"): continue
		
		var json_data = JSON.parse_string(trimmed)
		if json_data is Dictionary and json_data.has("pkg_name"):
			Global.soar_db[json_data["pkg_name"].to_lower()] = json_data
			
func get_installed() -> void:
	var output = []
	var err = OS.execute(Global.soar_path, ["info", "-j", "--no-color"], output)
	if err: push_error("ERROR: ",err, " Failed to read installed package list")
	if output.is_empty():
		return
	var raw_text = output[0]
	var lines = raw_text.split("\n", false)
	
	for line in lines:
		var trimmed = line.strip_edges()
		if not trimmed.begins_with("{"): continue
		if not trimmed.contains("pkg_name"): continue
		var json = JSON.parse_string(trimmed)
		Global.installed[json.pkg_name.to_lower()] = json

func load_fallback() -> void:
	Global.soar_db = JSON.parse_string(FileAccess.get_file_as_string("res://soar.json"))
	if Global.soar_db.is_empty():
		push_error("ERROR: Failed to load soar.json")
		get_tree().quit()


#func get_metadata_dictionary() -> Dictionary:
	#var output = []
	#var result = {}
	#OS.execute("appstreamcli", ["status"], output)
	#
	#var current_path = ""
	#var groups_passed = false
	#
	#for line in output[0].split("\n"):
		#var trimmed = line.strip_edges()
		#if "Other metadata sources:" in line: groups_passed = true
		#if !groups_passed: continue
		#
		#if trimmed.begins_with("/") or trimmed.begins_with("* /"):
			#current_path = trimmed.replace("* ", "").strip_edges()
			#if DirAccess.dir_exists_absolute(current_path):
				#result[current_path] = true
	#return result

#func get_metadata_files(metadata_paths: Dictionary) -> void:
	#var valid_names = ["appstream.xml", "catalog.xml", "swcatalog.xml"]
	#for dir_path in metadata_paths.keys():
		#for f_name in valid_names:
			#var full_path = str(dir_path) + "/" + f_name
			#if FileAccess.file_exists(full_path):
				#get_app_dictionary(full_path)

#func get_app_dictionary(path: String) -> void:
	#var x = XML.parse_file(path)
	#for component_node in x.root.children:
		#if component_node.name == "component":
			#var app_data = {}
			#var c = component_node.to_dict().children
			#
			## 1. Get ID and Name
			#app_data["id"] = c.id.__content__ if c.has("id") else ""
			#var app_name = c.name.__content__ if c.has("name") else "Unknown"
			#app_data["name"] = app_name
			#app_data["url"] = ""
			#if c.has("url"):
				#app_data["url"] = c.url.__content__
			#var full_desc = ""
			#if c.has("description"):
				#var desc_node = c.description
				#if desc_node.children.has("p"):
					#full_desc = desc_node.children.p.__content__
			#app_data["description"] = full_desc
			#app_data["license"] = c.project_license.__content__ if c.has("project_license") else ""
			#metadata_db[app_name.to_lower()] = app_data

#func debug_key_overlap():
	#var soar = []
	#var metadata = []
	#var matching = {}
	#
	#for key in Global.soar_db.keys():
		#if not metadata_db.has(key):
			#soar.append(key)
			#continue
		#matching[key] = 0
		#
	#for key in metadata_db.keys():
		#if not Global.soar_db.has(key):
			#metadata.append(key)
			#continue
		#matching[key] = 0
	#
	#print_debug("Only soar_db: ",Global.soar_db)
	##print_debug("Only metadata_db: ",metadata)
	#print_debug("Matching: ",matching.keys().size())

func check_appstreamcli() -> bool:
	return OS.execute("which", ["appstreamcli"], []) == 0

#func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	#versions.clear()
	#var output = []
	#var err = OS.execute(Global.soar_path, ["Q", apps.get_item_text(index),"--json", "--no-color"], output)
	#if err: push_error("ERROR: ",err)
	#var lines = output[0].split("\n")
	#Global.current_db = JSON.parse_string(str(lines))
	#for app in Global.current_db:
		#var trimmed = app.strip_edges()
		#if trimmed == "" or !trimmed.begins_with("{"): continue
		#
		#var json_data = JSON.parse_string(trimmed)
		#versions.add_item(json_data.pkg_id)
		#if (Global.installed.has(apps.get_item_text(index)) and
			#Global.installed[apps.get_item_text(index)].has(json_data.pkg_id)):
			#apps.set_item_custom_bg_color(apps.item_count-1,Color.DARK_SLATE_GRAY)
		#versions.set_item_tooltip(versions.item_count-1, json_data.build_id + " : " + json_data.version)
		#_on_item_list_item_selected(0)
#
#func _on_item_list_item_selected(index: int) -> void:
	#var item = JSON.parse_string(Global.current_db[index])
	#description.bbcode_enabled = true
	#var to_arr = func(val): 
		#return JSON.parse_string(val) if typeof(val) == TYPE_STRING else val
	#var txt = ""
	#var header = "[b][color=cyan]%s[/color][/b][color=green]#%s[/color]:[color=yellow]%s[/color]" % [item.pkg_name, item.pkg_id, item.repo_name]
	#
	#txt += "▦ Name          │ " + header + "\n"
	#txt += "────────────────┼──────────────────────────────────────────────────────────\n"
#
	## Content Rows
	#txt += "✎ Description   │ " + str(item.description) + "\n"
	#txt += "► Version       │ [color=cornflower_blue]" + str(item.version) + "[/color]\n"
#
	#var size_mib = snapped(float(item.size) / (1024 * 1024), 0.01)
	#txt += "■ Size          │ " + str(size_mib) + " MiB\n"
	#txt += "⚿ Checksum      │ " + str(item.bsum) + " (blake3)\n"
#
	## Homepages with Blue Links
	#var homes = to_arr.call(item.homepages)
	#for i in range(homes.size()):
		#var label = "⌂ Homepages     │ " if i == 0 else "                │ "
		#txt += label + "[color=dodger_blue][url]" + homes[i] + "[/url][/color]\n"
#
	#txt += "¶ Licenses      │ " + str(to_arr.call(item.licenses)).replace("[", "").replace("]", "").replace("\"", "") + "\n"
#
	## Notes
	#var notes = to_arr.call(item.notes)
	#for i in range(notes.size()):
		#var label = "• Notes         │ " if i == 0 else "                │ "
		#txt += label + notes[i] + "\n"
		#
	## Technical Metadata
	#txt += "▣ Type          │ [color=orchid]" + str(item.pkg_type) + "[/color]\n"
	#txt += "⚒ Build CI      │ [color=dodger_blue][url]" + str(item.build_action) + "[/url][/color] (" + str(item.build_id) + ")\n"
	#txt += "☀ Build Date    │ " + str(item.build_date) + "\n"
	#txt += "✎ Build Log     │ [color=dodger_blue][url]" + str(item.build_log) + "[/url][/color]\n"
	#txt += "✐ Build Script  │ [color=dodger_blue][url]" + str(item.build_script) + "[/url][/color]\n"
	#txt += "➜ GHCR Blob     │ " + str(item.ghcr_blob) + "\n"
	#txt += "▦ GHCR Package  │ [color=dodger_blue][url]" + str(item.ghcr_pkg) + "[/url][/color]\n"
	#txt += "➤ Index         │ [color=dodger_blue][url]" + str(item.pkg_webpage) + "[/url][/color]"
#
	#txt += "[/font_family]"
	#description.text = txt
