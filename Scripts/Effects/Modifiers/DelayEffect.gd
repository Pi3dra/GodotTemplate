class_name DelayEffect
extends Effect

var duration: float


func _init(p_duration: float) -> void:
	duration = p_duration


func start() -> Tween:
	var tween := target.create_tween()
	tween.tween_interval(duration)

	return tween 
