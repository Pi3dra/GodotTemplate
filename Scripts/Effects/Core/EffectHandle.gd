class_name EffectHandle
extends RefCounted


signal finished
var is_finished := false


func complete() -> void:
	if is_finished:
		return

	is_finished = true
	finished.emit()


func on_finished(callback: Callable) -> void:
	if is_finished:
		callback.call()
	else:
		finished.connect(callback, CONNECT_ONE_SHOT)
