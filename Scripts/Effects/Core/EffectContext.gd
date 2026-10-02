### Represents a single run of an Effect, this allows defining a single Effect,
### and running it on multiple nodes at once i.e avoids sharing the state
class_name EffectContext
extends RefCounted

signal finished
signal ended(run: EffectContext)

var effect: Effect
var target: Node
var done := false
var was_cancelled := false
var data := {} # per-run scratch space for effects (sprite, origin, child runs...)

var _tween: Tween
var _timer: Tween


func _init(p_effect: Effect, p_target: Node) -> void:
	effect = p_effect
	target = p_target


func start() -> void:
	effect._begin(self)


func on_finished(cb: Callable) -> EffectContext:
	if done:
		if not was_cancelled:
			cb.call()
	else:
		finished.connect(cb, CONNECT_ONE_SHOT)
	return self


# --- finish helpers (effects call these) ---

func use_tween(tween: Tween) -> void:
	_tween = tween
	_tween.finished.connect(finish)


func finish_after(seconds: float) -> void:
	_timer = target.create_tween()
	_timer.tween_interval(seconds)
	_timer.finished.connect(finish)


func finish_on_signal(sig: Signal) -> void:
	sig.connect(finish, CONNECT_ONE_SHOT) # stale connection is harmless: finish() is guarded


# --- lifecycle ---

func finish() -> void:
	_end(false)


func cancel() -> void:
	_end(true)


func _end(cancelled: bool) -> void:
	if done:
		return
	done = true
	was_cancelled = cancelled

	for t in [_tween, _timer]:
		if t and t.is_valid():
			t.kill()
	_tween = null
	_timer = null

	effect._cleanup(self, cancelled)

	if not cancelled:
		finished.emit()

	ended.emit(self)

	for sig in [finished, ended]:
		for c in sig.get_connections():
			sig.disconnect(c.callable)

	data.clear()

var paused := false

func pause() -> void:
	if done or paused:
		return
	paused = true
	for t in [_tween, _timer]:
		if t and t.is_valid():
			t.pause()
	effect._on_pause(self)


func resume() -> void:
	if done or not paused:
		return
	paused = false
	for t in [_tween, _timer]:
		if t and t.is_valid():
			t.play()
	effect._on_resume(self)
