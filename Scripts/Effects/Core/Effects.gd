class_name Effect
extends RefCounted

#region API

signal finished # normal completion only
signal ended(effect: Effect) # finished or cancelled, used by the manager

var target: Node
var done := false
var was_cancelled := false
var _tween: Tween


## To indicate the effect to stop in the effect manager use this name
func get_effect_name() -> StringName:
	var script: Script = get_script()
	var n := script.get_global_name()
	# fallback for scripts without class_name
	return n if n != &"" else StringName(script.resource_path)


## Override this is where you actually implement the effect
func _start() -> Tween:
	return null


## Override to undo side effects (stop a sound, remove a material...).
## Called once when the effect finishes or is cancelled.
func _cleanup(_cancelled: bool) -> void:
	pass


func play(p_target: Node, name: StringName = &"") -> Effect:
	assert(target == null, "Effects are single-use: create a new one per play.")
	center_pivot(p_target)
	target = p_target
	EffectManager.play(self, name)
	return self


func _run_as_child(parent: Effect) -> void:
	target = parent.target
	_begin()


## Chainable. Runs cb on normal completion, immediately if already finished.
func on_finished(cb: Callable) -> Effect:
	if done:
		if not was_cancelled:
			cb.call()
	else:
		finished.connect(cb, CONNECT_ONE_SHOT)
	return self


func _begin() -> void:
	_tween = _start()
	if _tween == null:
		_finish()
	else:
		_tween.finished.connect(_finish)


func _finish() -> void:
	if done:
		return
	done = true
	if _tween and _tween.is_valid():
		_tween.kill() # e.g. the sound ended before its duration timer
	_tween = null
	_cleanup(false)
	finished.emit()
	ended.emit(self)
	_clear_connections()


func cancel() -> void:
	if done:
		return
	done = true
	was_cancelled = true
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null
	ended.emit(self)
	_clear_connections() # drops pending on_finished callbacks, so they never fire


func _clear_connections() -> void:
	for sig in [finished, ended]:
		for c in sig.get_connections():
			sig.disconnect(c.callable)


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


static func play_sound(
		sound_name: String,
		duration := 1.,
		volume_db := 0.0,
		pitch := 1.0,
		loop := false,
):
	return SoundEffect.new(sound_name, volume_db, pitch, loop, duration)


static func fade_sound(target_db := 0, duration := 15):
	return FadeSoundEffect.new(target_db, duration)


static func pitch_sound(target_pitch_scale := 1., duration := 15):
	return PitchSoundEffect.new(target_pitch_scale, duration)

#endregion
