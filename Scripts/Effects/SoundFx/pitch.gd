class_name PitchSoundEffect
extends Effect

@export var target_pitch_scale: float
@export var duration: float


func _init(
		pitch,
		p_duration,
) -> void:
	target_pitch_scale = pitch
	duration = p_duration


func _begin(run: EffectContext) -> void:
	var target := run.target

	if target == null:
		run.finish()
		return

	var tween = target.create_tween()
	tween.tween_property(target, "pitch_scale", target_pitch_scale, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	run.use_tween(tween)
