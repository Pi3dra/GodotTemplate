class_name Effect
extends RefCounted

func execute(_context: EffectContext) -> EffectHandle:
	push_error("Effect.execute() must be implemented")
	return null

#region modifiers

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


static func center_pivot(target) -> void:
	if target is Control:
		target.pivot_offset = target.size / 2.0

#endregion

#region EFFECTS

static func punch(
		duration := 0.2,
		strength := 0.2,
		behavior := PunchEffect.Behavior.IN,
) -> Effect:
	return PunchEffect.new(
		strength,
		duration,
		behavior,
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
		degrees: float = 90.0,
		reset: bool = false,
) -> Effect:
	return RotateEffect.new(duration, degrees, reset)


static func flip(
		duration: float = 0.3,
		orientation: FlipEffect.Orientation = FlipEffect.Orientation.VERTICAL,
		mirror: bool = false,
) -> Effect:
	return FlipEffect.new(orientation, duration, mirror)


static func delay(duration: float = 0.3):
	return DelayEffect.new(duration)


static func add_shader(shaderpath: String, duration: float = -1):
	return ShaderEffect.new(shaderpath, duration)


static func spawn_animation(
		spriteframe_path: String,
		animation_name = "default",
		duration = -1,
		pos = Vector2(0, 0),
):
	return ParticleEffect.new(spriteframe_path, animation_name, duration, pos)


static func spawn_text(
		text,
		duration = 1.,
		strength = 1.,
		effects = null,
		position = Vector2(0, 0),
):
	return TextParticle.new(text, duration, strength, effects, position)

static func rainbow(duration: float = 3.0, saturation: float = 1.0, value: float = 1.0):
	return RainbowEffect.new(duration, saturation, value)

static func scale(target_scale: Vector2 = Vector2(1.5, 1.5), duration = 1.):
	return ScaleEffect.new(target_scale, duration)


static func color(target_color: Color = Color.RED, duration = 1.):
	return ColorEffect.new(target_color, duration)


static func move(target_pos: Vector2, duration: float = 1., add: bool = true):
	return MoveEffect.new(target_pos, duration, add)

static func play_sound(sound_name: String,
		duration := 1.,
		volume_db := 0.0,
		pitch := 1.0,
		loop := false):
	return SoundEffect.new(sound_name, volume_db, pitch, loop,duration)

static func fade_sound(target_db := 0, duration := 15):
	return FadeSoundEffect.new(target_db, duration)

static func pitch_sound(target_pitch_scale := 1., duration := 15):
	return PitchSoundEffect.new(target_pitch_scale, duration)
	
#endregion
