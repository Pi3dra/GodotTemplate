class_name ParallelEffect
extends Effect


var effects: Array[Effect]
var _child_handles: Array[EffectHandle] = []


func _init(p_effects: Array[Effect]) -> void:
	effects = p_effects


func execute(context: EffectContext) -> EffectHandle:
	var handle := EffectHandle.new()

	if effects.is_empty():
		handle.complete()
		return handle

	var remaining := [effects.size()]  # single-element array = shared mutable box
	_child_handles.clear()

	for effect in effects:
		var child_handle := effect.execute(context)
		_child_handles.append(child_handle)

		child_handle.on_finished(
			func():
				remaining[0] -= 1
				if remaining[0] == 0:
					handle.complete()
		)

	return handle
