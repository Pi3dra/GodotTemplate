extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UI.manager.hide_overlay(UI.NAME.ARENA)

	SoundManager.instance.play_sound("Level1", false)
	SoundManager.instance.play_sound("Level2", false)
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Transition", true, true)

	var tween = create_tween()
	tween.tween_property(self, "material:shader_parameter/progress", 39.0, 1.0)
	tween.tween_callback(tween_finished)


func tween_finished() -> void:
	queue_free()
