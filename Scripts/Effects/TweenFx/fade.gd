class_name FadeEffect
extends Effect

var duration: float
var fade_out: bool


func _init(
		p_duration,
		p_fade_out,
) -> void:
	duration = p_duration
	fade_out = p_fade_out

func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return 

	var tween := target.create_tween()

	if fade_out:
		tween.tween_property(
			target,
			"modulate:a",
			0,
			duration * 0.5,
		)
	else:
		tween.tween_property(
			target,
			"modulate:a",
			1,
			duration * 0.5,
		).from(0.0)

	run.use_tween(tween)
