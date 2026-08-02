extends Interface

@onready var first_button = $Label/Play


func _ready():
	#This is needed to allow controller navigation without having to click first
	first_button.grab_focus()


func _on_play_pressed() -> void:
	Main.manager.push_world(WorldManager.WORLDS.MAIN_WORLD)


func _on_settings_pressed() -> void:
	UI.manager.switch_ui(UIManager.UI.SETTINGS, true)
