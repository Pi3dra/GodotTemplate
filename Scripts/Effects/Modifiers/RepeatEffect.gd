class_name RepeatEffect
extends Effect

var effect: Effect
var times: int


func _init(p_effect: Effect = null, p_times := 1) -> void:
	effect = p_effect
	times = p_times


func _begin(run: EffectContext) -> void:
	run.data.count = 0
	_next(run)


func _next(run: EffectContext) -> void:
	if run.done:
		return
	if run.data.count >= times:
		run.finish()
		return

	run.data.count += 1
	var child := EffectContext.new(effect, run.target)
	run.data.current = child
	child.on_finished(_next.bind(run)) # connect before start, so instant children still chain
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
