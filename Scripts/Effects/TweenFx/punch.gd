class_name PunchEffect
extends Effect

enum Behavior { IN, OUT }

var behavior: PunchEffect.Behavior
var strength: float
var duration: float


func _init(
		p_strength,
		p_duration,
		p_behavior,
) -> void:
	strength = p_strength
	duration = p_duration
	behavior = p_behavior


func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return

	var original_scale = target.scale
	var tween := target.create_tween()

	var target_scale = original_scale / (1.0 + strength)
	if behavior == PunchEffect.Behavior.OUT:
		target_scale = original_scale * (1.0 + strength)

	tween.tween_property(
		target,
		"scale",
		target_scale,
		duration * 0.5,
	)

	tween.tween_property(
		target,
		"scale",
		original_scale,
		duration * 0.5,
	)

	run.use_tween(tween)
