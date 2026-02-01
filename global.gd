extends Node

var current_db = {}
var installed:Dictionary = {}
#var installed:Array = []
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

func get_installed() -> bool:
	installed = {}
	var output = []
	var err = OS.execute(soar_path, ["info", "-j", "--no-color"], output)
	if err: push_error("ERROR: ",err, " Failed to read installed package list")
	if output.is_empty():
		return false
	var raw_text = output[0]
	var lines = raw_text.split("\n", false)
	for line in lines:
		var trimmed = line.strip_edges()
		if not trimmed.begins_with("{"): continue
		if not trimmed.contains("pkg_name"): continue
		var json = JSON.parse_string(trimmed)
		for ver:String in soar_db[json.pkg_name].keys():
			var dict:Dictionary = soar_db[json.pkg_name][ver]
			if !(dict.repo_name == json.repo_name
				&& dict.pkg_name == json.pkg_name):
					continue
			if !installed.has(json.pkg_name):
				installed[json.pkg_name] = {}
			installed[json.pkg_name][ver] = {
				"repo_name":json.repo_name,
				"pkg_name":json.pkg_name,
			}
	return true
