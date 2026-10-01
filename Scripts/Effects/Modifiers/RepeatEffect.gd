class_name RepeatEffect
extends Effect

var factory: Callable # func() -> Effect
var times: int
var _count := 0
var _current: Effect


func _init(p_factory: Callable, p_times: int) -> void:
	factory = p_factory
	times = p_times


func _begin() -> void:
	_count = 0
	_next()


func _next() -> void:
	if done:
		return
	if _count >= times:
		_current = null
		_finish()
		return

	_count += 1
	_current = factory.call()
	_current.on_finished(_next)
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
