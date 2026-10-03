class_name ParallelEffect
extends Effect

var effects: Array[Effect]


func _init(p_effects: Array[Effect] = []) -> void:
	effects = p_effects


func _begin(run: EffectContext) -> void:
	if effects.is_empty():
		run.finish()
		return

	var children: Array[EffectContext] = []
	run.data.children = children
	run.data.remaining = effects.size() # set before starting, so instant children can't hit 0 early

	# Create all runs first, so a cancel during startup can reach every child.
	for e in effects:
		var child := EffectContext.new(e, run.target)
		children.append(child)
		child.on_finished(_on_child_finished.bind(run)) # connect before start, so instant children count

	for child in children:
		child.start()


func _on_child_finished(run: EffectContext) -> void:
	if run.done:
		return
	run.data.remaining -= 1
	if run.data.remaining == 0:
		run.finish()


func _cleanup(run: EffectContext, cancelled: bool) -> void:
	if not cancelled:
		return
	for child in run.data.get("children", []):
		child.cancel() 


func _on_pause(run: EffectContext) -> void:
	for child in run.data.get("children", []):
		child.pause()


func _on_resume(run: EffectContext) -> void:
	for child in run.data.get("children", []):
		child.resume()
