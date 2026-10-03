class_name RainbowEffect
extends Effect

var saturation: float
var value: float
var duration: float


func _init(
		p_duration,
		p_saturation,
		p_value,
) -> void:
	duration = p_duration
	saturation = p_saturation
	value = p_value


func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return

	var tween := target.create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	var colors = [
		Color.from_hsv(0.0, saturation, value),
		Color.from_hsv(0.17, saturation, value),
		Color.from_hsv(0.33, saturation, value),
		Color.from_hsv(0.5, saturation, value),
		Color.from_hsv(0.67, saturation, value),
		Color.from_hsv(0.83, saturation, value),
		Color.from_hsv(1.0, saturation, value),
	]
	for c in colors:
		tween.tween_property(target, "modulate", c, duration / colors.size())
	
	run.use_tween(tween)
