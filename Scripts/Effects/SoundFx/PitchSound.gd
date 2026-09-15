extends Effect

class_name PitchSoundEffect


var target_pitch_scale
var duration


func _init(
		pitch,
		p_duration,
) -> void:
	target_pitch_scale = pitch
	duration = p_duration

func execute(context: EffectContext) -> EffectHandle:
	var target := context.target 
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var tween = target.create_tween()
	tween.tween_property(target, "pitch_scale", target_pitch_scale, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(handle.complete)

	return handle
