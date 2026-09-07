class_name Effect
extends RefCounted

func execute(_context: EffectContext) -> EffectHandle:
	push_error("Effect.execute() must be implemented")
	return null


func then(effect: Effect) -> Effect:
	return SequenceEffect.new(
		[
			self,
			effect,
		],
	)


func with(effect: Effect) -> Effect:
	return ParallelEffect.new(
		[
			self,
			effect,
		],
	)


func repeat(times: int) -> Effect:
	return RepeatEffect.new(self, times)


func play(target: Node) -> EffectHandle:
	center_pivot(target)
	var context := EffectContext.new(target)
	return execute(context)


static func center_pivot(target: CanvasItem) -> void:
	if target is Control:
		target.pivot_offset = target.size / 2.0


static func punch(
		duration := 0.2,
		strength := 0.2,
		behavior := PunchEffect.Behavior.IN
) -> Effect:
	return PunchEffect.new(
		strength,
		duration,
		behavior
	)


static func fade(
		duration := 0.2,
		out := false,
) -> Effect:
	return FadeEffect.new(
		duration,
		out,
	)


static func shake(
		duration: float = 0.3,
		strength: float = 10.0,
		shakes: int = 5,
		axis: Vector2 = Vector2.ONE,
) -> Effect:
	return ShakeEffect.new(duration, strength, shakes, axis)


static func rotate(
		duration: float = 0.3,
		degrees: float = 360.0,
		reset: bool = false,
) -> Effect:
	return RotateEffect.new(duration, degrees, reset)


static func flip(duration: float, orientation: FlipEffect.Orientation, mirror: bool) -> Effect:
	return FlipEffect.new(orientation, duration, mirror)
