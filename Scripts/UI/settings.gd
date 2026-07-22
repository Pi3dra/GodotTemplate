extends Interface


func _on_save_settings_pressed() -> void:
	UI.manager.switch_ui(UIManager.UI.MAIN_MENU, false)


#region AUDIO

func _on_master_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_sfx_slider_value_changed(value: float) -> void:
	pass # Replace with function body.

#endregion

#region DISPLAY

func _on_brightness_slider_value_changed(value: float) -> void:
	pass # Replace with function body.

func _on_contrast_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
	
#endregion

#region ACCESIBILITY

func _on_time_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_font_slider_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_vfx_slider_value_changed(value: float) -> void:
	pass # Replace with function body.
	
#endregion

#region LANGUAGE

# https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html

func _on_en_pressed() -> void:
	TranslationServer.set_locale("en")

func _on_fr_pressed() -> void:
	TranslationServer.set_locale("fr")

func _on_sp_pressed() -> void:
	TranslationServer.set_locale("es")


#endregion
