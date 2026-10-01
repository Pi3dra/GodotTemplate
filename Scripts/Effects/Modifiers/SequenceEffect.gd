class_name SequenceEffect
extends Effect

var effects: Array[Effect]
var _current: Effect


func _init(p_effects: Array[Effect]) -> void:
	effects = p_effects


func _begin() -> void:
	_run_next(0)


func _run_next(index: int) -> void:
	if done:
		return
	if index >= effects.size():
		_current = null
		_finish()
		return

	_current = effects[index]
	_current.on_finished(_run_next.bind(index + 1)) # connect before starting, so instant effects still chain
	_current._run_as_child(self)


func cancel() -> void:
	if _current:
		_current.cancel()
		_current = null
	super()


func pause() -> void:
	if _current:
		_current.pause()


func resume() -> void:
	if _current:
		_current.resume()
