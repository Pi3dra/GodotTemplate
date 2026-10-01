extends Node

# target instance id -> { effect name: Effect }
var _running: Dictionary = {}


## Called by Effect.play(). Playing a name that's already running on this
## target replaces (cancels) the previous one.
func play(effect: Effect, name: StringName = &"") -> void:
	if name == &"":
		name = effect.get_effect_name()
	var target := effect.target

	# Cancel first: it can erase the target's whole entry, so do it before get_or_add.
	stop(target, name)

	effect._begin()
	if effect.done: # finished instantly (e.g. _start returned null)
		return

	var id := target.get_instance_id()
	_running.get_or_add(id, {})[name] = effect
	effect.ended.connect(_release.bind(id, name))

	# Cancel everything if the node leaves the tree, so entries don't linger.
	var cb := stop_all.bind(target)
	if not target.tree_exiting.is_connected(cb):
		target.tree_exiting.connect(cb, CONNECT_ONE_SHOT)


# Emitted args come first: (effect, then the bound id and name).
func _release(effect: Effect, id: int, name: StringName) -> void:
	var effects: Dictionary = _running.get(id, {})
	if effects.get(name) == effect: # ignore if it was already replaced
		effects.erase(name)
	if effects.is_empty():
		_running.erase(id)


# --- Commands -----------------------------------------------------------

func stop(target: Node, name: StringName) -> void:
	var effect: Effect = _running.get(target.get_instance_id(), {}).get(name)
	if effect:
		effect.cancel()


func stop_all(target: Node) -> void:
	# values() returns a copy, so erasing during cancel is safe.
	for effect in _running.get(target.get_instance_id(), {}).values():
		effect.cancel()


func pause(target: Node, name: StringName) -> void:
	var effect: Effect = _running.get(target.get_instance_id(), {}).get(name)
	if effect:
		effect.pause()


func resume(target: Node, name: StringName) -> void:
	var effect: Effect = _running.get(target.get_instance_id(), {}).get(name)
	if effect:
		effect.resume()


func pause_all(target: Node) -> void:
	for effect in _running.get(target.get_instance_id(), {}).values():
		effect.pause()


func resume_all(target: Node) -> void:
	for effect in _running.get(target.get_instance_id(), {}).values():
		effect.resume()


func is_playing(target: Node, name: StringName = &"") -> bool:
	var effects: Dictionary = _running.get(target.get_instance_id(), {})
	return not effects.is_empty() if name == &"" else effects.has(name)


## Cancel everything everywhere, e.g. on scene change.
func stop_everything() -> void:
	for id in _running.keys():
		for effect in _running.get(id, {}).values():
			effect.cancel()
