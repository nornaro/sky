extends ItemList

@onready var apps:ItemList = %Apps
@onready var description:RichTextLabel = %Description
@onready var webjson:Node = %HTTPRequest
func _ready() -> void:
	apps.item_clicked.connect(_on_apps_item_clicked)

func _on_apps_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	clear()
	query_info(apps.get_item_text(index))
	var app = Global.soar_db[apps.get_item_text(index)].values()
	
	for json_data:Dictionary in app:
		add_item(json_data.pkg_id)
		if (Global.installed.has(apps.get_item_text(index)) and
			Global.installed[apps.get_item_text(index)].pkg_id  == json_data.pkg_id):
			apps.set_item_custom_bg_color(apps.item_count-1,Color.DARK_SLATE_GRAY)
		set_item_tooltip(item_count-1, json_data.version)
	description._on_version_selected__(0)

func query_info(pkg_name) -> bool:
	var output = []
	var err = OS.execute(Global.soar_path, ["Q", pkg_name,"--json", "--no-color"], output)
	if err: push_error("ERROR: ",err); return false
	var lines = output[0].split("\n")
	Global.current_db = JSON.parse_string(str(lines))
	if !Global.current_db or Global.current_db.is_empty(): return false
	for app in Global.current_db:
		var trimmed = app.strip_edges()
		if trimmed == "" or !trimmed.begins_with("{"): continue
		var json_data:Dictionary = JSON.parse_string(trimmed)
		json_data.erase("message")
		json_data.erase("level")
		Global.add(json_data)
	return true
