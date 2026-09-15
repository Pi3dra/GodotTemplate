class_name RepeatEffect
extends Effect


var effect: Effect
var times: int
var _child_handle : EffectHandle


func _init(
	p_effect: Effect,
	p_times: int
) -> void:
	effect = p_effect
	times = p_times

func execute(context: EffectContext) -> EffectHandle:
	var handle := EffectHandle.new()

	_run(context, handle, 0)

	return handle


func _run(
	context: EffectContext,
	handle: EffectHandle,
	count: int
) -> void:

	if count >= times:
		handle.complete()
		return

	var child_handle := effect.execute(context)
	_child_handle = child_handle

	child_handle.on_finished(
		func():
			_run(
				context,
				handle,
				count + 1
			)
	)
	
