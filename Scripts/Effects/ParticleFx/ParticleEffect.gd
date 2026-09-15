extends Effect
class_name ParticleEffect

var path : String
var animation_name : String
var duration : float 
var position : Vector2

func _init(
	spriteframe_path : String,
	anim_name : String,
	p_duration : float,
	pos : Vector2
) -> void:
	path = spriteframe_path
	animation_name = anim_name
	duration = p_duration
	position = pos



func execute(context: EffectContext) -> EffectHandle:
	var target := context.target as CanvasItem
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle

	var animation_frames: SpriteFrames = load(path)
	var effect := AnimatedSprite2D.new()
	effect.sprite_frames = animation_frames
	effect.play(animation_name) 
	effect.position = position
	target.add_child(effect)

	var looping = animation_frames.get_animation_loop_mode(animation_name) != SpriteFrames.LoopMode.LOOP_NONE
	
	if not looping :
		effect.animation_finished.connect(
			func():
				handle.complete()
				effect.queue_free()
		)
	elif looping && duration != -1:
		var tween := context.target.create_tween()
		tween.tween_interval(duration)
		tween.finished.connect(
			func():
				handle.complete()
				effect.queue_free()
		)
	else:
		handle.complete()

	return handle
