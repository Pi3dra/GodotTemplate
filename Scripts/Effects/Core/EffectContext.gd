class_name EffectContext
extends RefCounted
## Represents a single run of an Effect, this allows defining a single Effect,
## and running it on multiple nodes at once i.e avoids sharing the state

signal finished
signal ended(run: EffectContext)

## The effect tied to this context
var effect: Effect
## The target node on which this effect will play
var target: Node
var done := false
var was_cancelled := false
## per-run scratch space for effects (sprite, origin, child runs) [br]
## Store here anything that might be different between different runs of a same effect
var data := { }
var paused := false

## Change this if you don't want the effect to do cleanup
var do_cleanup := true

var _tween: Tween
var _timer: Tween
var _spawned: Array[Node] = []


func _init(p_effect: Effect, p_target: Node) -> void:
	effect = p_effect
	target = p_target


func start() -> void:
	effect._begin(self)


## Helper function to execute a callable when an effect ends
func on_finished(cb: Callable) -> EffectContext:
	if done:
		if not was_cancelled:
			cb.call()
	else:
		finished.connect(cb, CONNECT_ONE_SHOT)
	return self

# --- helpers (effects call these) ---


## Provide a tween which will indicate when the effect has ended.[br][br]
## These helpers
## [codeblock]
## use_tween()
## finish_after()
## finish_on_signal()
## [/codeblock]
## Are compatible between them, an effect can use all, and will end on the first one which triggers.
func use_tween(tween: Tween) -> void:
	_tween = tween
	_tween.finished.connect(finish)


## Provide a duration in seconds in which to end the effect[br][br]
## These helpers
## [codeblock]
## use_tween()
## finish_after()
## finish_on_signal()
## [/codeblock]
## Are compatible between them, an effect can use all, and will end on the first one which triggers.
func finish_after(seconds: float) -> void:
	_timer = target.create_tween()
	_timer.tween_interval(seconds)
	_timer.finished.connect(finish)


## Finish when a signal is emitted[br][br]
## These helpers
## [codeblock]
## use_tween()
## finish_after()
## finish_on_signal()
## [/codeblock]
## Are compatible between them, an effect can use all, and will end on the first one which triggers.
func finish_on_signal(sig: Signal) -> void:
	sig.connect(finish, CONNECT_ONE_SHOT) # stale connection is harmless: finish() is guarded


## Adds a node the effect spawned, to either the target or the manager's root.
## The node is remembered so it can be cleaned up automatically.
func spawn(
		node: Node,
		parent_mode: Effect.Parent = Effect.Parent.TARGET,
		offset := Vector2.ZERO,
) -> Node:
	var parent: Node = target if parent_mode == Effect.Parent.TARGET else EffectManager.root_node
	if parent == null or not is_instance_valid(parent):
		node.queue_free()
		return null

	parent.add_child(node)
	_spawned.append(node)

	# Placement (only meaningful for 2D / Control nodes)
	if node is Node2D or node is Control:
		if parent_mode == Effect.Parent.TARGET:
			node.position = offset
		else:
			node.global_position = _target_anchor() + offset
	return node


## Where the target is on the canvas, so ROOT-parented nodes spawn on it.
func _target_anchor() -> Vector2:
	if target is CanvasItem:
		return (target as CanvasItem).get_global_transform().origin
	return Vector2.ZERO

# --- lifecycle ---


## called when the effects finishes, either manually, or by helpers
## if enabled (by default it is) it will call the _cleanup callback from effect
func finish() -> void:
	_end(false)


## Cancels an effect, called manually, or automatically by the [EffectManager][br]
## if enabled (by default it is) it will call the _cleanup callback from effect
## A cancelled effect won't emit the finished signal
func cancel() -> void:
	_end(true)


## Kills all tweens and timers, if
## cleanup is enabled, calls it, queue frees any
## spawned nodes, and emits finished if it isnt cancelled.
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

	if do_cleanup:
		effect._cleanup(self, cancelled)

	for n in _spawned:
		if is_instance_valid(n):
			n.queue_free()

	if not cancelled:
		finished.emit()

	ended.emit(self)

	for sig in [finished, ended]:
		for c in sig.get_connections():
			sig.disconnect(c.callable)

	data.clear()


## Pauses an effect, it's tweens and it's timers.
## Calls the _on_pause callback from the effect
func pause() -> void:
	if done or paused:
		return
	paused = true
	for t in [_tween, _timer]:
		if t and t.is_valid():
			t.pause()
	effect._on_pause(self)


## Resumes an effect, it's tweens and it's timers.
## Calls the _on_resume callback from the effec
func resume() -> void:
	if done or not paused:
		return
	paused = false
	for t in [_tween, _timer]:
		if t and t.is_valid():
			t.play()
	effect._on_resume(self)
