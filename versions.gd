extends ItemList

@onready var apps:ItemList = %Apps
@onready var description:RichTextLabel = %Description
@onready var webjson:Node = %HTTPRequest

var selected = null

func _ready() -> void:
	apps.item_clicked.connect(_on_apps_item_clicked)

func _on_apps_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	%Description.selected = 0
	clear()
	query_info(apps.get_item_text(index))
	var json = Global.soar_db[apps.get_item_text(index)]
	for value:Dictionary in json.values():
		add_item(value.pkg_id)
		set_item_tooltip(item_count-1, value.version)
		if !Global.installed.has(value.pkg_name):
			continue
		if !Global.installed[value.pkg_name].has(value.pkg_id):
			continue
		if item_count == 0:
			continue
		set_item_custom_bg_color(item_count - 1, Color.DARK_SLATE_GRAY)
	description._on_version_selected(0)

func query_info(pkg_name) -> bool:
	var output = []
	var err = OS.execute(Global.soar_path, ["Q", pkg_name,"--json", "--no-color"], output)
	if err: push_error("ERROR: ",err); return false
	var json = JSON.parse_string(str(output[0].split("\n")))
	for app in json:
		if !app: continue
		var trimmed = app.strip_edges()
		if trimmed == "" or !trimmed.begins_with("{"): continue
		var json_data:Dictionary = JSON.parse_string(trimmed)
		json_data.erase("message")
		json_data.erase("level")
		Global.add(json_data)
	return true
