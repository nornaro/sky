extends Button
class_name Remove

@onready var apps: ItemList = %Apps
@onready var versions: ItemList = %Versions
@onready var info_bar: RichTextLabel = %InfoBar

var is_removing: bool = false
var current_pid: int = -1

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
		versions_to_remove.append(versions.get_selected_items()[0])
	for idx in versions.item_count:
		var ver_text = versions.get_item_text(idx)
		if Global.installed.has(pkg_name) and Global.installed[pkg_name].has(ver_text):
			versions_to_remove.append(idx)

	if versions_to_remove.is_empty():
		info_bar.text = "[color=yellow]No installed versions found to remove.[/color]"
		return

	is_removing = true
	text = "Cancel"
	info_bar.text = "[color=Darkorange]Removing %s...[/color]" % pkg_name
	
	var task_data = {
		"pkg_name": pkg_name,
		"version_indices": versions_to_remove,
		"app_idx": app_idx
	}
	WorkerThreadPool.add_task(_do_remove_background.bind(task_data))

func _do_remove_background(data: Dictionary):
	for ver_idx in data.version_indices:
		var pkg_id = versions.get_item_text(ver_idx)
		var full_name = data.pkg_name + "#" + pkg_id
		current_pid = OS.create_process(Global.soar_path, ["r", full_name, "-y", "--json", "--no-color"])
		if current_pid == -1: continue
		while OS.is_process_running(current_pid):
			OS.delay_msec(100)
		call_deferred("_update_item_ui", ver_idx)
	call_deferred("_finalize_remove_ui", data)

func _update_item_ui(ver_idx: int):
	versions.set_item_custom_bg_color(ver_idx, Color(0, 0, 0, 0))

func _finalize_remove_ui(data: Dictionary):
	is_removing = false
	current_pid = -1
	text = "Remove"
	
	Global.get_installed()
	var wait_time: float = 60.0
	var elapsed: float = 0.0
	
	info_bar.text = "[color=yellow]Verifying removal... (Click Remove to skip wait)[/color]"
	
	while elapsed < wait_time:
		if not Global.installed.has(data.pkg_name):
			break
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
		if int(elapsed * 10) % 20 == 0:
			Global.get_installed()

	apps.set_item_custom_bg_color(data.app_idx, Color(0, 0, 0, 0))
	info_bar.text = "[color=green]Removal completed and verified.[/color]"
	
