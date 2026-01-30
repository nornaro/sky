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
	for app in Global.soar_db.keys():
		apps.add_item(app)
		if !Global.installed.has(app):
			continue
		apps.set_item_custom_bg_color(apps.item_count-1,Color.DARK_SLATE_GRAY)

func parse_soar_json() -> void:
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

func check_appstreamcli() -> bool:
	return OS.execute("which", ["appstreamcli"], []) == 0
