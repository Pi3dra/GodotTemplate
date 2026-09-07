extends Control

func _on_punch_pressed() -> void:
	Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).play($Punch)
	
func _on_punch_in_pressed() -> void:
	Effect.punch(.2, 0.2, PunchEffect.Behavior.IN).play($PunchIn)

func _on_fade_in_pressed() -> void:
	Effect.fade(1., false).play($FadeIn)

func _on_fade_out_pressed() -> void:
	Effect.fade(1., true).play($FadeOut)

func _on_shake_pressed() -> void:
	Effect.shake().play($Shake)


func _on_rotate_pressed() -> void:
	Effect.rotate().play($Rotate)


func _on_flip_v_pressed() -> void:
	Effect.flip(1., FlipEffect.Orientation.VERTICAL, false).play($FlipV)

func _on_flip_h_pressed() -> void:
	Effect.flip(1., FlipEffect.Orientation.HORIZONTAL, true).play($FlipH)


func _on_sequence_pressed() -> void:
	var effect = Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).then(Effect.fade(1., true))
	effect.play($Sequence)
