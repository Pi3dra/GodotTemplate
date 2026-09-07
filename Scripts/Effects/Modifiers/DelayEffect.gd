class_name DelayEffect
extends Effect


var duration: float


func _init(p_duration: float) -> void:
	duration = p_duration


func execute(context: EffectContext) -> EffectHandle:
	var handle := EffectHandle.new()

	var tween := context.target.create_tween()

	tween.tween_interval(duration)

	tween.finished.connect(handle.complete)

	return handle
