class_name ShakeEffect
extends Effect


var strength: float
var duration: float
var shakes: int
var axis : Vector2


func _init(
	p_duration: float = 0.3, 
	p_strength: float = 10.0,
	p_shakes: int = 5, 
	p_axis: Vector2 = Vector2.ONE
) -> void:

	duration = p_duration 
	strength = p_strength
	shakes = p_shakes
	axis = p_axis

func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var original_pos: Vector2 = target.position
	var tween := target.create_tween()
	
	## axis: Vector2.RIGHT for horizontal only, Vector2.DOWN for vertical only, Vector2.ONE for both.
	for i in range(shakes):
		var offset = Vector2(
			randf_range(-strength, strength) * axis.x,
			randf_range(-strength, strength) * axis.y
		)
		tween.tween_property(target, "position", original_pos + offset, duration / (shakes * 2))
		tween.tween_property(target, "position", original_pos, duration / (shakes * 2))

	tween.finished.connect(handle.complete)

	return handle
