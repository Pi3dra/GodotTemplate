class_name MoveEffect
extends Effect

var new_position: Vector2
var duration: float
var add: bool


func _init(
		new_pos: Vector2,
		p_duration: float,
		p_add: bool,
) -> void:
	new_position = new_pos
	duration = p_duration
	add = p_add


func _begin(run: EffectContext) -> void:
	var target := run.target as CanvasItem

	if target == null:
		run.finish()
		return

	var original_position = target.position
	var target_position = new_position
	if add:
		target_position = original_position + new_position

	var tween := target.create_tween()
	tween.tween_property(
		target,
		"position",
		target_position,
		duration,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	run.use_tween(tween)
