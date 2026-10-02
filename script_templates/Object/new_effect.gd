# meta-name: Effect
# meta-description: Basic skeleton for defining your own Effects
# meta-space-indent: 4
class_name _CLASS_
extends Effect

var strength: float
var duration: float


func _init(
		p_duration: float,
		p_strength: float,
) -> void:
	duration = p_duration
	strength = p_strength

## Override this. Start the effect; make sure _finish() gets called eventually
## (directly, or through _use_tween / _finish_after / _finish_on_signal).
func _begin() -> void:
	if target == null:
		_finish()

	_finish() # default: do nothing, end instantly


## Override to undo side effects (stop a sound, remove a material...).
## Called once when the effect finishes or is cancelled.
func _cleanup(_cancelled: bool) -> void:
	pass

## To pause anything that may need pausing
func _on_pause(_run: EffectRun) -> void:
	pass

## To resume anything that may need pausing
func _on_resume(_run: EffectRun) -> void:
	pass
