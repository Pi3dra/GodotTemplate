class_name ParticleEffect
extends Effect

var path: String
var animation_name: StringName
var duration: float # negative = play to the end (or loop until cancelled)
var position: Vector2


func _init(
		p_path := "",
		p_animation_name: StringName = &"default",
		p_duration := -1.0,
		p_position := Vector2.ZERO,
) -> void:
	path = p_path
	animation_name = p_animation_name
	duration = p_duration
	position = p_position


func _begin(run: EffectContext) -> void:
	var frames := load(path) as SpriteFrames
	if run.target == null or frames == null or not frames.has_animation(animation_name):
		run.finish()
		return

	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.position = position
	run.target.add_child(sprite)
	sprite.play(animation_name)
	run.data.sprite = sprite

	# A non-looping animation ends the run when it finishes.
	if not frames.get_animation_loop(animation_name):
		run.finish_on_signal(sprite.animation_finished)

	# Optional time limit: cuts a loop, or caps a long one-shot. First one wins.
	if duration >= 0.0:
		run.finish_after(duration)

	# Looping with duration < 0 runs until cancelled, by design.


func _cleanup(run: EffectContext, _cancelled: bool) -> void:
	var sprite: AnimatedSprite2D = run.data.get("sprite")
	if is_instance_valid(sprite):
		sprite.queue_free()


func _on_pause(run: EffectContext) -> void:
	var sprite: AnimatedSprite2D = run.data.get("sprite")
	if is_instance_valid(sprite):
		sprite.pause()


func _on_resume(run: EffectContext) -> void:
	var sprite: AnimatedSprite2D = run.data.get("sprite")
	if is_instance_valid(sprite):
		sprite.play(animation_name)
