extends Button

@onready var apps:ItemList = %Apps
@onready var versions:ItemList = %Versions


func _ready() -> void:
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	var app:int = apps.get_selected_items()[0]
	var selected:int = 0
	if !versions.get_selected_items().is_empty(): 
		selected = versions.get_selected_items()[0]
	var pkg_name:String = apps.get_item_text(app)
	if apps.get_selected_items().is_empty():return
	if versions.get_selected_items().is_empty():
		for idx:int in versions.item_count:
			var version = versions.get_item_text(idx)
			if !Global.installed[pkg_name].has(version):
				continue
			remove(pkg_name,idx)
		return
	remove(pkg_name,selected)
	
func remove(pkg_name:String,selected:int) -> void:
	var pkg_id:String = versions.get_item_text(selected)
	var output:Array = []
	var err = OS.execute(Global.soar_path, ["r", pkg_name+"#"+pkg_id, "-y", "--json", "--no-color"], output)
	
	if err != 0 or output[0].is_empty():
		%InfoBar.text = "[color=red]Removal of %s failed[/color]" % pkg_name+"#"+pkg_id
		return
	%InfoBar.text = "[color=black]%s[/color]" % JSON.parse_string(output[0]).get("message", "Removed")
	versions.set_item_custom_bg_color(selected, Color(0, 0, 0, 0))
	apps.set_item_custom_bg_color(apps.get_selected_items()[0], Color(0, 0, 0, 0))
	Global.get_installed()
