class_name FadeEffect
extends Effect


var duration: float
var fade_out: bool


func _init(
	p_duration := 0.2,
	p_fade_out := false
) -> void:
	duration = p_duration
	fade_out = p_fade_out


func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle


	var tween := target.create_tween()
	
	if fade_out :
		tween.tween_property(
			target,
			"modulate:a",
			0,
			duration * 0.5
		)
	else:
		tween.tween_property(
			target,
			"modulate:a",
			1,
			duration * 0.5,
		).from(0.0)
	
	tween.finished.connect(handle.complete)

	return handle
