class_name SequenceEffect
extends Effect

var effects: Array[Effect]


func _init(p_effects: Array[Effect] = []) -> void:
	effects = p_effects


func _begin(run: EffectContext) -> void:
	_next(run, 0)


func _next(run: EffectContext, index: int) -> void:
	if run.done:
		return
	if index >= effects.size():
		run.finish()
		return

	var child := EffectContext.new(effects[index], run.target)
	run.data.current = child
	child.on_finished(_next.bind(run, index + 1)) # connect before start, so instant children still chain
	child.start()


func _cleanup(run: EffectContext, cancelled: bool) -> void:
	if cancelled and run.data.get("current"):
		run.data.current.cancel()


func _on_pause(run: EffectContext) -> void:
	if run.data.get("current"):
		run.data.current.pause()


func _on_resume(run: EffectContext) -> void:
	if run.data.get("current"):
		run.data.current.resume()
