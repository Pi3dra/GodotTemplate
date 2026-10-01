class_name ParallelEffect
extends Effect

var effects: Array[Effect]
var _remaining := 0


func _init(p_effects: Array[Effect]) -> void:
	effects = p_effects


func _begin() -> void:
	if effects.is_empty():
		_finish()
		return

	_remaining = effects.size() # set before starting, so instant children can't hit 0 early
	for e in effects:
		e.on_finished(_on_child_finished)
		e._run_as_child(self)


func _on_child_finished() -> void:
	_remaining -= 1
	if _remaining == 0:
		_finish()


func cancel() -> void:
	for e in effects:
		e.cancel() # no-op for children that are already done
	super()


func pause() -> void:
	for e in effects:
		e.pause()


func resume() -> void:
	for e in effects:
		e.resume()
