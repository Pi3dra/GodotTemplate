class_name ParallelEffect
extends Effect


var effects: Array[Effect]


func _init(p_effects: Array[Effect]) -> void:
	effects = p_effects


func execute(context: EffectContext) -> EffectHandle:
	var handle := EffectHandle.new()

	if effects.is_empty():
		handle.complete()
		return handle

	var remaining := effects.size()

	for effect in effects:
		var child_handle := effect.execute(context)

		child_handle.finished.connect(
			func():
				remaining -= 1

				if remaining == 0:
					handle.complete()
		)

	return handle
