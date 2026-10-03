extends Effect

class_name RotateEffect

@export var degrees: float # how far to rotate
@export var duration: float
@export var reset_after: bool # snap back to 0 when done


func _init(
		p_duration: float,
		p_degrees: float,
		reset: bool,
) -> void:
	duration = p_duration
	degrees = p_degrees
	reset_after = reset


func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return

	var tween := target.create_tween()

	tween.tween_property(
		target,
		"rotation_degrees",
		target.rotation_degrees + degrees,
		duration,
	)

	if reset_after:
		tween.tween_callback(func(): target.rotation_degrees = 0.0)

	run.use_tween(tween)
