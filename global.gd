extends Node

#@onready var apps: ItemList = %Apps
#@onready var versions: ItemList = %Versions
#@onready var info_bar: RichTextLabel = %InfoBar
var installed:Dictionary = {}
var soar_db:Dictionary = {}
var soar_path = "soar"
var waiting:Dictionary = {}
var versions:ItemList
var apps:ItemList
var info_bar:RichTextLabel
var install:Button
var update:Button
var remove:Button
signal soar_task_finished(type:String, pid:int, data:Dictionary)
signal soar_task_canleled(type:String, pid:int, data:Dictionary)

func _ready() -> void:
	soar_task_finished.connect(_finished)
	soar_task_canleled.connect(_canleled)
	if OS.execute(soar_path,[]):
		soar_path = "/bin/soar"
	if OS.execute(soar_path,[]):
		soar_path = "~/.local/bin/soar"
	if OS.execute(soar_path,[]):
		soar_path = "/home/sugo/.local/bin/soar"
	
	versions = get_tree().get_first_node_in_group("Versions")
	apps = get_tree().get_first_node_in_group("Apps")
	info_bar = get_tree().get_first_node_in_group("InfoBar")
	install = get_tree().get_first_node_in_group("Install")
	update = get_tree().get_first_node_in_group("Update")
	remove = get_tree().get_first_node_in_group("Remove")

func add(json_data:Dictionary) -> void:
	var pkg_name:String = json_data["pkg_name"].to_lower()
	if !soar_db.has(pkg_name):
		soar_db[pkg_name] = {}
	if !soar_db[pkg_name].has(json_data.pkg_id):
		soar_db[pkg_name][json_data.pkg_id] = {}
	soar_db[pkg_name][json_data.pkg_id] = json_data

func parse_soar_cancel(pid:int) -> void:
	soar_task_canleled.emit(waiting[pid][0], pid, waiting[pid][1])

func parse_soar_json(type:String, pid:int, data:Dictionary = {}) -> void:
	installed.clear()
	var output = []
	var err = OS.execute(Global.soar_path , ["list", "-j", "--no-color"], output)
	var lines = output[0].split("\n")
	if err: 
		push_error("ERROR: ",err, " Loading fallback soar.json")
		lines = FileAccess.get_file_as_string("res://soar.json").split("\n")
		
	for line:String in lines:
		var trimmed = line.strip_edges()
		if trimmed == "" or !trimmed.begins_with("{"): continue
		
		var json_data:Dictionary = JSON.parse_string(trimmed)
		if !json_data is Dictionary or !json_data.has("pkg_name"):
			continue
		Global.add(json_data)
		if line.contains("✓"):
			if !Global.installed.has(json_data.pkg_name):
				Global.installed[json_data.pkg_name] = {}
			Global.installed[json_data.pkg_name][json_data.pkg_id] = {}
	soar_task_finished.emit(type, pid, data)
	waiting.erase(pid)

func _finished(type:String, pid:int, data:Dictionary):
	match type:
		"Install":
			OS.kill(pid)
			install.text = install.name
			install.is_installing = false
			info_bar.text = "[color=yellow]Verifying install...[/color]"
			if Global.installed.has(data.pkg_name):
				if Global.installed[data.pkg_name].has(data.pkg_id):
					versions.set_item_custom_bg_color(data.ver_idx, Color.DARK_SLATE_GRAY)
					apps.set_item_custom_bg_color(data.app_idx, Color.DARK_SLATE_GRAY)
					if install.pink:
						info_bar.text = "[color=pink]Uninstall by instal cancellation cancelled.[/color]"
						install.pink = false
						return
					info_bar.text = "[color=green]Successfully Installed: " + data.pkg_name + "[/color]"
					return
			info_bar.text = "[color=red]Installation failed.[/color]"
		"Updata":
			update.text = update.name
			pass
		"Remove":
			OS.kill(pid)
			remove.text = remove.name
			remove.is_removing = false
			info_bar.text = "[color=yellow]Verifying removal...[/color]"
			if Global.installed.has(data.pkg_name):
				if Global.installed[data.pkg_name].has(data.pkg_id):
					push_error("Failed to remove " + data.pkg_name)
					install._do_install(data)
					info_bar.text = "[color=red]"+"Failed to remove " + data.pkg_id+"[/color]"
					return
			versions.set_item_custom_bg_color(data.ver_idx, Color(0, 0, 0, 0))
			if remove.pink:
				info_bar.text = "[color=pink]Uninstall by instal cancellation cancelled.[/color]"
				install.pink = false
				return
			info_bar.text = "[color=green]Removal of " + data.pkg_id +" completed.[/color]"
			if !Global.installed.has(data.pkg_name):
				apps.set_item_custom_bg_color(data.app_idx, Color(0, 0, 0, 0))


func _canleled(type:String, pid:int, data:Dictionary = {}) -> void:
	info_bar.text = "[color=red]Attempting to cancel...[/color]"
	match type:
		"Install":
			OS.kill(pid)
			install.text = install.name
			install.is_installing = false
			if Global.installed.has(data.pkg_name):
				if Global.installed[data.pkg_name].has(data.pkg_id):
					install.pink = true
					return
			info_bar.text = "[color=grey]Installation cancelled.[/color]"
			data["version_indices"] = [data.ver_idx]
			remove._do_remove(data)
		"Updata":
			update.text = update.name
			pass
		"Remove":
			OS.kill(pid)
			remove.text = remove.name
			remove.is_removing = false
			if (!Global.installed.has(data.pkg_name)
				or !Global.installed[data.pkg_name].has(data.pkg_id)):
					remove.pink = true
					return
			install._do_install(data)
	waiting.erase(pid)
