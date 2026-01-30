extends Node

var current_db#:Dictionary = {}
var installed:Dictionary = {}
var soar_db:Dictionary = {}
var soar_path = "soar"

func _ready() -> void:
	if OS.execute(soar_path,[]):
		soar_path = "~/.local/bin/soar"
	if OS.execute(soar_path,[]):
		soar_path = "~/.local/bin/soar"
	if OS.execute(soar_path,[]):
		soar_path = "/home/sugo/.local/bin/soar"
