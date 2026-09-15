class_name ColorEffect
extends Effect

var duration: float
var target_color: Color


func _init(
		p_color: Color,
		p_duration: float,
) -> void:
	duration = p_duration
	target_color = p_color


func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var tween := target.create_tween()
	var start_color := target.modulate

	tween.tween_method(
	func(t: float):
		var rgb := start_color.lerp(target_color, t)

		target.modulate = Color(
			rgb.r,
			rgb.g,
			rgb.b,
			target.modulate.a # ← preserve whatever alpha currently is
		),
	0.0,
	1.0,
	duration * 0.5
)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	tween.finished.connect(handle.complete)

	return handle
