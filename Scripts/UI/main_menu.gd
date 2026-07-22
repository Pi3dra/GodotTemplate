extends Interface


func _on_play_pressed() -> void:
	Main.manager.push_world(WorldManager.WORLDS.MAIN_WORLD)



func _on_settings_pressed() -> void:
	UI.manager.switch_ui(UIManager.UI.SETTINGS, true)
