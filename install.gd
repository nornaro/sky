extends Button

var is_installing: bool = false
var current_pid: int = -1
var selected: int = 0 

@onready var apps: ItemList = %Apps
@onready var versions: ItemList = %Versions
@onready var info_bar: RichTextLabel = %InfoBar

func _ready():
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	if is_installing:
		if current_pid != -1:
			OS.kill(current_pid)
			info_bar.text = "[color=red]Attempting to cancel...[/color]"
		return

	if apps.get_selected_items().is_empty(): return
	var app_idx: int = apps.get_selected_items()[0]
	if not versions.get_selected_items().is_empty():
		selected = versions.get_selected_items()[0]
	var pkg_name: String = apps.get_item_text(app_idx)
	var pkg_id: String = versions.get_item_text(selected)

	is_installing = true
	text = "Cancel"
	info_bar.text = "[color=Darkorange]Installing: " + pkg_name + "#" + pkg_id + "[/color]"

	var task_data = {
		"name": pkg_name,
		"id": pkg_id,
		"app_idx": app_idx,
		"ver_idx": selected
	}
	WorkerThreadPool.add_task(_do_install_background.bind(task_data))

func _do_install_background(data: Dictionary):
	var pkg_full_name = data.name + "#" + data.id
	current_pid = OS.create_process(Global.soar_path, ["i", pkg_full_name, "-y", "-q", "--no-color", "--portable"])
	
	if current_pid == -1:
		data["success"] = false
		data["error"] = "Failed to launch process"
		call_deferred("_finalize_install_ui", data)
		return

	while OS.is_process_running(current_pid):
		OS.delay_msec(200)
		
	var attempts = 0
	var is_verified = false
	while attempts < 10:
		attempts += 1
		var check_output = []
		OS.execute("bash", ["-c", "soar info --no-color | grep " + data.name], check_output, true)
		
		if not check_output.is_empty() and check_output[0].contains(data.name):
			is_verified = true
			break
		OS.delay_msec(500)
	
	data["success"] = is_verified
	call_deferred("_finalize_install_ui", data)

func _finalize_install_ui(data: Dictionary):
	is_installing = false
	current_pid = -1
	text = "Install"
	
	if data.success:
		versions.set_item_custom_bg_color(data.ver_idx, Color.DARK_SLATE_GRAY)
		apps.set_item_custom_bg_color(data.app_idx, Color.DARK_SLATE_GRAY)
		info_bar.text = "[color=Darkgreen]Successfully Installed: " + data.name + "[/color]"
		return
	info_bar.text = "[color=red]Installation failed or cancelled.[/color]"
