extends ItemList

@onready var apps:ItemList = %Apps
@onready var description:RichTextLabel = %Description

func _ready() -> void:
	apps.item_clicked.connect(_on_apps_item_clicked)

# Called when the node enters the scene tree for the first time.
func _on_apps_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	print(index)
	clear()
	#var output = []
	#var err = OS.execute(Global.soar_path, ["Q", apps.get_item_text(index),"--json", "--no-color"], output)
	#if err: push_error("ERROR: ",err)
	#var lines = output[0].split("\n")
	#Global.current_db = JSON.parse_string(str(lines))
	#for app in Global.current_db:
	for app:String in Global.soar_db.keys():
		#var trimmed = app.strip_edges()
		#if trimmed == "" or !trimmed.begins_with("{"): continue
		#print(app)
		var json_data = Global.soar_db[app]
		add_item(json_data.pkg_id)
		if (Global.installed.has(apps.get_item_text(index)) and
			Global.installed[apps.get_item_text(index)].pkg_id  == json_data.pkg_id):
			apps.set_item_custom_bg_color(apps.item_count-1,Color.DARK_SLATE_GRAY)
		set_item_tooltip(item_count-1, json_data.build_id + " : " + json_data.version)
		description._on_app_selected(app,0)
