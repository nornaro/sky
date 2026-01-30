extends Node

var current_db = {}
var installed:Dictionary = {}
var soar_db:Dictionary = {}
var soar_path = "soar"

func _ready() -> void:
	if OS.execute(soar_path,[]):
		soar_path = "/bin/soar"
	if OS.execute(soar_path,[]):
		soar_path = "~/.local/bin/soar"
	if OS.execute(soar_path,[]):
		soar_path = "/home/sugo/.local/bin/soar"

func add(json_data:Dictionary) -> void:
	var pkg_name:String = json_data["pkg_name"].to_lower()
	if !soar_db.has(pkg_name):
		soar_db[pkg_name] = {}
	if !soar_db[pkg_name].has(json_data.pkg_id):
		soar_db[pkg_name][json_data.pkg_id] = {}
	soar_db[pkg_name][json_data.pkg_id].merge(json_data)
