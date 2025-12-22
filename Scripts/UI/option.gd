extends Control

var menu: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# To use options screen outside of the menu
	if get_parent().get_child(0).name == "Menu":
		menu = get_parent().get_child(0) as Control
	else:
		menu = null


func _on_return_pressed() -> void:
	# To use options screen outside of the menu
	if menu != null:
		menu.visible = true
		queue_free()


func _on_english_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_french_pressed() -> void:
	TranslationServer.set_locale("fr")


func _on_spanish_pressed() -> void:
	TranslationServer.set_locale("es")
