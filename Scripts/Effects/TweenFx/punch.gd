class_name PunchEffect
extends Effect


enum Behavior {IN , OUT}

var behavior : PunchEffect.Behavior
var strength: float
var duration: float


func _init(
	p_strength := 0.2,
	p_duration := 0.2,
	p_behavior := Behavior.OUT
) -> void:

	strength = p_strength
	duration = p_duration
	behavior = p_behavior


func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var original_scale = target.scale

	var tween := target.create_tween()
	
	var target_scale = original_scale / (1.0 + strength)
	if behavior == PunchEffect.Behavior.OUT:
		target_scale = original_scale * (1.0 + strength)
		
	tween.tween_property(
		target,
		"scale",
		target_scale,
		duration * 0.5
	)
	
	tween.tween_property(
		target,
		"scale",
		original_scale,
		duration * 0.5
	)

	tween.finished.connect(handle.complete)

	return handle
