extends HTTPRequest

@onready var http_request = self 

func load_app_details(pkg_name: String, pkg_webpage: String):
	var json_url = pkg_webpage.rstrip("/") + "/raw.json"
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		http_request.cancel_request()
	if http_request.request_completed.is_connected(_on_data_received):
		http_request.request_completed.disconnect(_on_data_received)
	http_request.request_completed.connect(_on_data_received.bind(pkg_name))
	var err = http_request.request(json_url)
	if err != OK: push_error("Failed to start request: ", err)

func _on_data_received(_result, response_code, _headers, body, _pkg_name):
	if http_request.request_completed.is_connected(_on_data_received):
		http_request.request_completed.disconnect(_on_data_received)
	if response_code != 200: return
	var json:Dictionary = JSON.parse_string(body.get_string_from_utf8())
	if json and typeof(json) == TYPE_DICTIONARY:
		Global.add(json)
