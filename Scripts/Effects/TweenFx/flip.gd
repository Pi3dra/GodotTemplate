extends Effect
class_name FlipEffect

enum Orientation { HORIZONTAL, VERTICAL }

@export var orientation: FlipEffect.Orientation 
@export var duration: float 
@export var mirror: bool  # true = end flipped (-1), false = end normal (1)

func _init(p_orientation : FlipEffect.Orientation, p_duration, p_mirror):
	orientation = p_orientation
	duration = p_duration
	mirror = p_mirror

func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()
	if target == null:
		handle.complete()
		return handle

	var tween := target.create_tween()
	var prop := "scale:x" if orientation == Orientation.HORIZONTAL else "scale:y"
	var start_val := 1.0
	var end_val := -1.0 if mirror else 1.0

	# shrink axis to 0
	tween.tween_property(target, prop, 0.0, duration * 0.5)
	# then expand back out (flipped or not, depending on `mirror`)
	tween.tween_property(target, prop, end_val, duration * 0.5)

	tween.finished.connect(handle.complete)
	return handle
