class_name ScaleEffect
extends Effect

var new_scale: Vector2
var duration: float

func _init(
	p_scale: Vector2,
	p_duration: float,
	) -> void:
	new_scale = p_scale
	duration = p_duration

func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var original_scale = target.scale
	var target_scale = original_scale * new_scale 

	var tween := target.create_tween()

	tween.tween_property(
		target,
		"scale",
		target_scale,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.finished.connect(handle.complete)

	return handle
