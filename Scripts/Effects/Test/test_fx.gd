extends Control

@onready var effect_layer = $EffectLayer


func _ready():
	EffectManager.root_node = effect_layer


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
	var effect = Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).then(Effect.shake()).then(Effect.fade(1., true))
	effect.play($Sequence)


func _on_parallel_pressed() -> void:
	var effect = Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).with(Effect.shake()).with(Effect.fade(1., true))
	effect.play($Parallel)


func _on_compositon_pressed() -> void:
	var effect = Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).with(Effect.shake()).then(Effect.fade(1., true))
	effect.play($Compositon)


func _on_repeat_pressed() -> void:
	var effect = Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).then(Effect.delay(1)).repeat(5)
	effect.play($Repeat)


func _on_all_pressed() -> void:
	var effect = Effect.punch(.2, 0.2, PunchEffect.Behavior.OUT).with(Effect.shake()).then(Effect.delay(1)).repeat(5).then(Effect.fade(1., true))
	effect.play($All)


func _on_shader_pressed() -> void:
	var effect = Effect.add_shader("res://Resources/Shaders/hlight.gdshader")
	effect.play($Shader/TextureRect)


func _on_spawn_pressed() -> void:
	var button = $Spawn
	var position = Effect.get_center(button)
	var effect = Effect.spawn_animation("res://Scripts/Effects/Test/Impact.tres", "default", 6, position)
	effect.play(button)


func _on_text_pressed() -> void:
	var text = $Text
	var position = Effect.get_center(text)
	var effect = Effect.spawn_text("[color=red]-10[/color]", 1., 1., null, position)
	effect.play(text)


func _on_color_pressed() -> void:
	var effect = Effect.color()
	effect.play($Color)


func _on_scale_pressed() -> void:
	var effect = Effect.scale()
	effect.play($Scale)


func _on_move_pressed() -> void:
	var effect = Effect.move(Vector2(5, 0), 1.0, true)
	effect.play($Move)


func _on_sound_pressed() -> void:
	var effect = Effect.play_sound("UIPress")
	effect.play($Sound)


func _on_complex_pressed() -> void:
	var center_pos = ($Complex/TextureRect.size) / 2
	var effect = ParallelEffect.new(
		[
			Effect.shake(),
			Effect.spawn_text("[color=red]-10[/color]", 1.0, 1.0, null, center_pos),
			Effect.spawn_animation("res://Scripts/Effects/Test/Impact.tres", "default", -1, center_pos),
			Effect.play_sound("RevolverShot", 0.9),
		],
	)
	var fade = ParallelEffect.new(
		[
			Effect.color(Color.RED, 0.5),
			Effect.fade(0.3, true),
		],
	)

	effect.then(fade).play($Complex/TextureRect)


func _on_fade_sound_pressed() -> void:
	var player = SoundManager.play("Crash-Landing", -50)
	var effect = Effect.fade_sound()
	effect.play(player)


func _on_pitch_sound_pressed() -> void:
	var player = SoundManager.play("Crash-Landing")
	var effect = Effect.pitch_sound(0.5, 5.)
	effect.play(player)


func _on_rainbow_pressed() -> void:
	Effect.rainbow().play($Rainbow)
