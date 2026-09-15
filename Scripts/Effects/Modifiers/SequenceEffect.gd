class_name SequenceEffect
extends Effect


var effects: Array[Effect]
var _current_handle: EffectHandle  # keeps it alive, this is ref counted so it needs to keep a ref


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

	_current_handle = effects[index].execute(context)

	_current_handle.on_finished(
		func():
			_run_next(context, handle, index + 1)
	)
