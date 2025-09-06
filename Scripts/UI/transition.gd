extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_ui.instance.hide()
	
	SoundManager.instance.play_sound("Level1", false)
	SoundManager.instance.play_sound("Level2", false)
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Transition", true, true)
	
	var lTween = create_tween()
	lTween.tween_property(self, "material:shader_parameter/progress", 39.0, 1.0)
	lTween.tween_callback(tween_finished)

func tween_finished() -> void:
	queue_free()
