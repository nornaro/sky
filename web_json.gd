extends Node

@onready var http_request = HTTPRequest.new()

# UI References - Adjust these to match your actual Node names
#@onready var title = $VBox/Title
#@onready var desc = $VBox/Description
#@onready var icon = $VBox/Icon
#@onready var size_label = $VBox/Grid/SizeValue
#@onready var version_label = $VBox/Grid/VersionValue

func _ready() -> void:
	add_child(http_request) 
	#load_app_details("steam", "https://pkgs.pkgforge.dev/repo/pkgcache/x86_64-linux/steam/runimage/archlinux/stable/steam")

func load_app_details(pkg_name: String, pkg_webpage: String):
	var json_url = pkg_webpage.rstrip("/") + "/raw.json"
	if http_request.request_completed.is_connected(_on_data_received):
		http_request.request_completed.disconnect(_on_data_received)
	http_request.request_completed.connect(_on_data_received.bind(pkg_name))
	
	http_request.request(json_url)

func _on_data_received(_result, response_code, _headers, body, key):
	if response_code != 200: return
	var json:Dictionary = JSON.parse_string(body.get_string_from_utf8())
	Global.soar_db[key] = json
	#print(Global.soar_db)
	#Global.soar_db[key].merge(json,true)
	
			
		# 2. Update UI
		#_fill_ui(Global.soar_db[key])

#func _fill_ui(data: Dictionary):
	#title.text = data.get("pkg_name", "Unknown").capitalize()
	#desc.text = data.get("description", "No description.")
	#size_label.text = data.get("ghcr_size", "N/A")
	#version_label.text = data.get("version", "N/A")
	#
	## Handle Icon
	#if data.has("icon"):
		#_fetch_icon(data["icon"])
#
#func _fetch_icon(url: String):
	#var icon_req = HTTPRequest.new()
	#add_child(icon_req)
	#icon_req.request_completed.connect(func(res, code, head, body):
		#var img = Image.new()
		#if img.load_png_from_buffer(body) == OK:
			#icon.texture = ImageTexture.create_from_image(img)
		#icon_req.queue_free()
	#)
	#icon_req.request(url)
