extends Node

func _ready() -> void:
	UIManager.root_node = $UI
	WorldManager.root_node = $World
	EffectManager.root_node = $Effects
	UIManager.invoke_ui(UIManager.UI.MAIN_MENU)
