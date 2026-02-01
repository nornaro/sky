extends Button

var is_installing: bool = false
var current_pid: int = -1
var selected: int = 0 
var pink:bool = false
@onready var apps: ItemList = %Apps
@onready var versions: ItemList = %Versions
@onready var info_bar: RichTextLabel = %InfoBar

func _ready():
	connect("pressed",_on_pressed)

func _on_pressed() -> void:
	if is_installing:
		if current_pid != -1:
			Global.call_deferred("parse_soar_cancel",current_pid)
			OS.kill(current_pid)
			info_bar.text = "[color=red]Attempting to cancel...[/color]"
			is_installing = false
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
		"pkg_name": pkg_name,
		"pkg_id": pkg_id,
		"app_idx": app_idx,
		"ver_idx": selected
	}
	_do_install(task_data)
	
func _do_install(task_data:Dictionary):
	WorkerThreadPool.add_task(_do_install_background.bind(task_data))
#
func _do_install_background(data: Dictionary):
	var pkg_full_name = data.pkg_name + "#" + data.pkg_id
	current_pid = OS.create_process(Global.soar_path, ["run", pkg_full_name, "-y", "-q", "--no-color", "--portable"])
	#Global.waiting[current_pid] = [name,data]
	#if current_pid == -1: return
	#while OS.is_process_running(current_pid):
		#OS.delay_msec(100)
	#Global.call_deferred("parse_soar_json",name, current_pid, data)
