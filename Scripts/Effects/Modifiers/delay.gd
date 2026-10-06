class_name DelayEffect
extends Effect
## Allows delaying an effect for a given duration in seconds, useful when composed with the SequenceEffect

@export var duration: float


func _init(p_duration: float) -> void:
	duration = p_duration


func _begin(run: EffectContext) -> void:
	run.finish_after(duration)
