class_name SequenceEffect
extends Effect


var effects: Array[Effect]


func _init(p_effects: Array[Effect]) -> void:
	effects = p_effects


func execute(context: EffectContext) -> EffectHandle:
	var handle := EffectHandle.new()

	_run_next(context, handle, 0)

	return handle


func _run_next(
	context: EffectContext,
	handle: EffectHandle,
	index: int
) -> void:

	if index >= effects.size():
		handle.complete()
		return

	var effect := effects[index]

	var child_handle := effect.execute(context)

	child_handle.finished.connect(
		func():
			_run_next(
				context,
				handle,
				index + 1
			)
	)
