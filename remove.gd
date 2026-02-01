extends Button
class_name Remove

@onready var apps: ItemList = %Apps
@onready var versions: ItemList = %Versions
@onready var info_bar: RichTextLabel = %InfoBar

var is_removing: bool = false
var current_pid: int = -1
var pink: bool = false

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if is_removing:
		if current_pid != -1:
			OS.kill(current_pid)
			info_bar.text = "[color=red]Cancelling removal...[/color]"
		return

	if apps.get_selected_items().is_empty(): return
	var app_idx: int = apps.get_selected_items()[0]
	var pkg_name: String = apps.get_item_text(app_idx)
	var versions_to_remove: Array[int] = []
	
	if !versions.get_selected_items().is_empty():
		versions_to_remove = [versions.get_selected_items()[0]]
	if versions.get_selected_items().is_empty():
		for idx in versions.item_count:
			var ver_text = versions.get_item_text(idx)
			if Global.installed.has(pkg_name) and Global.installed[pkg_name].has(ver_text):
				versions_to_remove.append(idx)

	if versions_to_remove.is_empty():
		info_bar.text = "[color=yellow]No installed versions found to remove.[/color]"
		return
	text = "Cancel"
	is_removing = true
	info_bar.text = "[color=Darkorange]Removing %s...[/color]" % pkg_name
	
	var task_data = {
		"pkg_name": pkg_name,
		"version_indices": versions_to_remove,
		"app_idx": app_idx
	}
	_do_remove(task_data)
	
func _do_remove(task_data:Dictionary):
	WorkerThreadPool.add_task(_do_remove_background.bind(task_data))

func _do_remove_background(data: Dictionary):
	for ver_idx in data.version_indices:
		var pkg_id:String = versions.get_item_text(ver_idx)
		var full_name = data.pkg_name + "#" + pkg_id
		current_pid = OS.create_process(Global.soar_path, ["r", full_name, "-y", "--json", "--no-color"])
		if current_pid == -1: continue
		while OS.is_process_running(current_pid):
			OS.delay_msec(100)
		data["pkg_id"] = pkg_id
		data["ver_idx"] = ver_idx
		Global.call_deferred("parse_soar_json",name, current_pid, data)
