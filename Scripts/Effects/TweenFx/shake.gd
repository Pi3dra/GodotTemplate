class_name ShakeEffect
extends Effect

var strength: float
var duration: float
var shakes: int
var axis: Vector2


## axis: Vector2.RIGHT for horizontal only, Vector2.DOWN for vertical only, Vector2.ONE for both.
func _init(
		p_duration: float,
		p_strength: float,
		p_shakes: int,
		p_axis: Vector2,
) -> void:
	duration = p_duration
	strength = p_strength
	shakes = p_shakes
	axis = p_axis


func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return
		
	var original_pos: Vector2 = target.position
	var tween := target.create_tween()

	for i in range(shakes):
		var offset = Vector2(
			randf_range(-strength, strength) * axis.x,
			randf_range(-strength, strength) * axis.y,
		)
		tween.tween_property(target, "position", original_pos + offset, duration / (shakes * 2))
		tween.tween_property(target, "position", original_pos, duration / (shakes * 2))

	run.use_tween(tween)
