extends Interface

@onready var first_button = $Label/Play


func _ready():
	#This is needed to allow controller navigation without having to click first
	first_button.grab_focus()


func _on_play_pressed() -> void:
	WorldManager.push_world(WorldManager.WORLDS.MAIN_WORLD)
	UIManager.remove(UIManager.UI.MAIN_MENU)


func _on_settings_pressed() -> void:
	UIManager.switch_ui(UIManager.UI.SETTINGS, UIManager.DisplayMode.HIDE)
