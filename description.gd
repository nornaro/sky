extends RichTextLabel

var container: VBoxContainer
var description_line: PackedScene = preload("res://description_line.tscn")
@onready var versions: ItemList = %Versions
@onready var apps: ItemList = %Apps

var link_regex = RegEx.new()
var selected = 0
@onready var icon = preload("res://Sky.png")

const FORMATTERS = {
	"Pkg": "_fmt_header",
	"pkg_name": "_fmt_header",
	"Size Raw": "_fmt_size",
	"Ghcr Size Raw": "_fmt_size",
	"size": "_fmt_size",
	"Shasum": "_fmt_sum",
	"bsum": "_fmt_sum",
	"Version Latest": "_fmt_magenta",
	"version": "_fmt_magenta",
	"Build Date": "_fmt_purple",
	"build_date": "_fmt_purple",
	"License": "_fmt_orchid",
	"licenses": "_fmt_orchid",
	"Tag": "_fmt_orchid",
	"pkg_type": "_fmt_orchid",
}

func _ready() -> void:
	link_regex.compile("^[a-z][a-z0-9+.-]*$")
	meta_clicked.connect(_on_link_clicked)
	versions.item_selected.connect(_on_version_selected)

func _on_mouse_entered() -> void: get_tree().call_group("desc_hide", "hide")
func _on_mouse_exited() -> void: get_tree().call_group("desc_hide", "show")
func _on_link_clicked(meta: Variant) -> void: OS.shell_open(str(meta))

func _on_version_selected(index: int) -> void:
	selected = index
	%Description.text = ""
	if is_instance_valid(container):
		container.queue_free()
	container = VBoxContainer.new()
	%Details.add_child(container)
	if apps.get_selected_items().is_empty():
		return
	var pkg_name = apps.get_item_text(apps.get_selected_items()[0])
	var version = versions.get_item_text(selected)
	var save_dir = OS.get_executable_path().get_base_dir().path_join("icons")
	if !Global.soar_db.has(pkg_name):return
	if !Global.soar_db[pkg_name].has(version):return
	Global.soar_db[pkg_name][version]["saved_icon"] = {"default":icon}
	if FileAccess.file_exists(save_dir+"/"+pkg_name+".res"):
		Global.soar_db[pkg_name][version]["saved_icon"] = {pkg_name:load(save_dir+"/"+pkg_name+".res")}
	if !Global.soar_db[pkg_name][version].has("pkg_webpage"):return
	%HTTPRequest.load_app_details(pkg_name, Global.soar_db[pkg_name][version].pkg_webpage)
	await %HTTPRequest.details_loaded
	var selected_app: Dictionary = Global.soar_db[pkg_name].values()[index]
	for key in selected_app.keys():
		var val = selected_app[key]
		if FORMATTERS.has(key) and has_method(FORMATTERS[key]):
			var txt_special = call(FORMATTERS[key], val, selected_app)
			_create_ui_row(key, txt_special)
			continue
		var txt_default = _resolve_value(val, key)
		_create_ui_row(key, txt_default)

func _create_ui_row(key: String, txt: String) -> void:
	if key.to_lower() == "level":return
	if key.to_lower() == "message":return
	match key.to_lower():
		"description","category","notes","homepages":
			text += txt + "\n\n"
	var instance = description_line.instantiate()
	container.add_child(instance)
	instance.get_node("Label").text = key.capitalize()
	
	var rtl: RichTextLabel = instance.get_node("RTL")
	rtl.bbcode_enabled = true
	rtl.tooltip_text = txt.strip_edges()
	rtl.text = txt.replace(", ",",\n").strip_edges()
	
	if not rtl.meta_clicked.is_connected(_on_link_clicked):
		rtl.meta_clicked.connect(_on_link_clicked)

func _resolve_value(val, key_context: String = "") -> String:
	var data = val
	
	if (typeof(val) == TYPE_STRING and 
		((val.begins_with("[") and val.ends_with("]")) or 
		(val.begins_with("{") and val.ends_with("}")))):
		var parsed = JSON.parse_string(val)
		if parsed != null: 
			data = parsed

	if typeof(data) == TYPE_ARRAY:
		var items = []
		for i in data:
			items.append(_resolve_value(i, key_context))
		return ", ".join(items)

	if typeof(data) == TYPE_DICTIONARY:
		var txt = ""
		for k in data.keys():
			txt += str(k) + ": " + _resolve_value(data[k], key_context) + "\n"
		return txt

	var s_val = str(data).strip_edges()
	if _is_link(s_val): return "[color=dodger_blue][url]%s[/url][/color]" % s_val
	if _is_hash(s_val): return "[color=dark_gray]%s[/color]" % s_val
	if key_context.to_lower().contains("version"): return "[color=magenta]%s[/color]" % s_val
	if key_context.to_lower().contains("shot"): return "[color=magenta]%s[/color]" % s_val
	if key_context.to_lower().contains("date"): return "[color=purple]%s[/color]" % s_val
	if key_context.to_lower() in ["licenses", "tag", "pkg_type"]: return "[color=orchid]%s[/color]" % s_val
	return s_val

func _is_link(val) -> bool:
	var s = str(val).strip_edges()
	if not ":" in s or s.length() < 4: return false
	var scheme = s.split(":", true, 1)[0].to_lower()
	return scheme.length() > 1 and link_regex.search(scheme)

func _is_hash(val) -> bool:
	var s = str(val).strip_edges()
	var lengths = [32, 40, 64, 128]
	return s.length() in lengths and s.is_valid_hex_number(false)

func _fmt_header(_v, item) -> String:
	var p_name = item.get("Pkg", item.get("pkg_name", "Unknown"))
	var p_rank = item.get("Rank", item.get("pkg_id", "0"))
	return "[b][color=cyan]%s[/color][/b] [color=green]#%s[/color]" % [p_name, p_rank]
func _fmt_magenta(v, _i) -> String: return "[color=magenta]%s[/color]" % str(v)
func _fmt_purple(v, _i) -> String: return "[color=purple]%s[/color]" % str(v)
func _fmt_orchid(v, _i) -> String: return "[color=orchid]%s[/color]" % str(v)
func _fmt_size(v, _i) -> String: return "%.2f MiB" % (float(v) / (1024 * 1024))
func _fmt_sum(v, _i) -> String: return "[color=dark_gray]%s[/color] [i][/i]" % str(v)
