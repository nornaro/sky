extends Node

var metadata_db = {}
@onready var apps:ItemList = %Apps
@onready var versions:ItemList = %Versions
@onready var description:RichTextLabel = %Description
@onready var apps_list:ScrollContainer = %AppList

func _ready() -> void:
	Global.soar_task_finished.connect(_on_soar_task_finished)
	if !check_appstreamcli():
		push_error("appstreamcli not found.")
		return
	
	Global.parse_soar_json(name, 0, {})

func _on_soar_task_finished(_type:String, pid:int,_data:Dictionary) -> void:
	if pid != 0: return
	for app in Global.soar_db.keys():
		apps.add_item(app)
		if !Global.installed.has(app):
			continue
		apps.set_item_custom_bg_color(apps.item_count-1,Color.DARK_SLATE_GRAY)


func load_fallback() -> void:
	Global.soar_db = JSON.parse_string(FileAccess.get_file_as_string("res://soar.json"))
	if Global.soar_db.is_empty():
		push_error("ERROR: Failed to load soar.json")
		get_tree().quit()

func check_appstreamcli() -> bool:
	return OS.execute("which", ["appstreamcli"], []) == 0
