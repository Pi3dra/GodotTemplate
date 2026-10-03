extends Node

var root_node 

# target instance id -> { effect name: EffectContext }
var _running: Dictionary = {}

func play(effect: Effect, target: Node, effect_name: StringName = &"") -> EffectContext:
	if effect_name == &"":
		effect_name = effect.get_effect_name()
	stop(target, effect_name)

	var run := EffectContext.new(effect, target)
	run.start()
	if run.done:
		return run

	var id := target.get_instance_id()
	_running.get_or_add(id, {})[effect_name] = run
	run.ended.connect(_release.bind(id, effect_name))
	# tree_exiting hook as before
	return run

# Emitted args come first: (effect, then the bound id and effect_name).
func _release(effect: EffectContext, id: int, effect_name: StringName) -> void:
	var effects: Dictionary = _running.get(id, {})
	if effects.get(effect_name) == effect: # ignore if it was already replaced
		effects.erase(effect_name)
	if effects.is_empty():
		_running.erase(id)


# --- Commands -----------------------------------------------------------

func stop(target: Node, effect_name: StringName) -> void:
	var effect: EffectContext = _running.get(target.get_instance_id(), {}).get(effect_name)
	if effect:
		effect.cancel()


func stop_all(target: Node) -> void:
	# values() returns a copy, so erasing during cancel is safe.
	for effect in _running.get(target.get_instance_id(), {}).values():
		effect.cancel()


func pause(target: Node, effect_name: StringName) -> void:
	var effect: EffectContext = _running.get(target.get_instance_id(), {}).get(effect_name)
	if effect:
		effect.pause()


func resume(target: Node, effect_name: StringName) -> void:
	var effect: EffectContext = _running.get(target.get_instance_id(), {}).get(effect_name)
	if effect:
		effect.resume()


func pause_all(target: Node) -> void:
	for effect in _running.get(target.get_instance_id(), {}).values():
		effect.pause()


func resume_all(target: Node) -> void:
	for effect in _running.get(target.get_instance_id(), {}).values():
		effect.resume()


func is_playing(target: Node, effect_name: StringName = &"") -> bool:
	var effects: Dictionary = _running.get(target.get_instance_id(), {})
	return not effects.is_empty() if effect_name == &"" else effects.has(effect_name)


## Cancel everything everywhere, e.g. on scene change.
func stop_everything() -> void:
	for id in _running.keys():
		for effect in _running.get(id, {}).values():
			effect.cancel()
