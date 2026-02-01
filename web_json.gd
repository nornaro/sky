extends HTTPRequest

@onready var http_request = self 
@onready var apps: ItemList = %Apps
@onready var versions: ItemList = %Versions
@onready var info_bar: RichTextLabel = %InfoBar
@onready var description: RichTextLabel = %Description
var save_dir = OS.get_executable_path().get_base_dir().path_join("icons")
signal details_loaded

func load_app_details(pkg_name: String, pkg_webpage: String):
	var json_url = pkg_webpage.rstrip("/") + "/raw.json"
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		http_request.cancel_request()
	http_request.request_completed.connect(_on_data_received.bind(pkg_name), CONNECT_ONE_SHOT)
	http_request.request(json_url)

func _on_data_received(_result, response_code, _headers, body, pkg_name):
	var ver = versions.get_item_text(description.selected)
	var app_data:Dictionary
	if Global.soar_db[pkg_name].has(ver):
		app_data = Global.soar_db[pkg_name][ver]
	if !app_data.has("saved_icon") or app_data.saved_icon.has("default"):
		app_data.saved_icon = {"default": description.icon}
	%AppIcon.texture = app_data.saved_icon.values()[0]
	if response_code != 200: 
		details_loaded.emit()
		return
	var json:Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json and typeof(json) == TYPE_DICTIONARY:
		if !app_data.get("saved_icon","default"):
			for key:String in json.keys():
				json[key]["saved_icon"] = app_data.saved_icon
		Global.add(json)
	if json.has("icon") and json.icon != "" and app_data.saved_icon.has("default"):
		download_icon(json.icon)
		return
	details_loaded.emit()
	
func download_icon(url: String):
	var icon_request = HTTPRequest.new()
	add_child(icon_request)
	icon_request.request_completed.connect(_on_icon_downloaded.bind(icon_request))
	
	var err = icon_request.request(url)
	if err != OK:
		icon_request.queue_free()
		details_loaded.emit()

func _on_icon_downloaded(_result, response_code, _headers, body, request_node):
	request_node.queue_free()
	if response_code != 200:
		details_loaded.emit()
		return
	var image = Image.new()
	var ext = ""
	for g:String in _headers:
		if !g.to_lower().contains("content-type"):
			continue
		var parts = g.split("/")
		if parts.size() > 1:
			ext = parts[1].split(";")[0].strip_edges().to_lower()
			if ext == "jpeg": ext = "jpg" 
		break
	if ext != "" and image.has_method("load_" + ext + "_from_buffer"):
		var err = image.call("load_" + ext + "_from_buffer", body)
		if err: push_error("Error: "+err+"Failed to load icon"); return
		var tex = ImageTexture.create_from_image(image)
		if apps.get_selected_items().is_empty():
			return
		var pkg_name = apps.get_item_text(apps.get_selected_items()[0])
		var ver = versions.get_item_text(description.selected)
		var save_path = save_dir.path_join(pkg_name + ".res")
		if not DirAccess.dir_exists_absolute(save_dir):
			DirAccess.make_dir_recursive_absolute(save_dir)
		var error = ResourceSaver.save(tex, save_path)
		if error != OK:
			push_error("Failed to save icon to local disk. Error: " + str(error))
			info_bar.text = "[color=orange]"+"Failed to save icon" + save_path + " to local disk. Error: " + str(error)+"[/color]"
		%AppIcon.texture = tex
		Global.soar_db[pkg_name][ver].saved_icon = {pkg_name: tex}
	details_loaded.emit()
