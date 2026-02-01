extends ItemList


func _on_search_bar_text_changed(new_text: String) -> void:
	clear()
	for app: String in Global.soar_db.keys():
		if new_text != "" and !app.contains(new_text):
			continue
		add_item(app)
		if !Global.installed.has(app):
			continue
		set_item_custom_bg_color(item_count - 1, Color.DARK_SLATE_GRAY)
