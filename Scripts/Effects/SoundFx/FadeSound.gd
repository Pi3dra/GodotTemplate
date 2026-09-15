extends Effect

class_name FadeSoundEffect


var target_db
var duration


func _init(
		p_db,
		p_duration,
) -> void:
	target_db = p_db
	duration = p_duration

func execute(context: EffectContext) -> EffectHandle:
	var target := context.target 
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var tween = target.create_tween()
	tween.tween_property(target, "volume_db", target_db, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(handle.complete)

	return handle
