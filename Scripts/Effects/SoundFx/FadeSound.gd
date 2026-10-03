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


func _begin(run: EffectContext) -> void:
	var target := run.target

	if target == null:
		run.finish()
		return 

	var tween = target.create_tween()
	tween.tween_property(target, "volume_db", target_db, duration)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	run.use_tween(tween)
