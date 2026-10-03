class_name DelayEffect
extends Effect

var duration: float


func _init(p_duration: float) -> void:
	duration = p_duration


func _begin(run : EffectContext) -> void:
	run.finish_after(duration)
