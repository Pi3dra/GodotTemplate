extends Effect

class_name ParticleEffect

var path: String
var animation_name: String
var duration: float
var position: Vector2


func _init(
		spriteframe_path: String,
		anim_name: String,
		p_duration: float,
		pos: Vector2,
) -> void:
	path = spriteframe_path
	animation_name = anim_name
	duration = p_duration
	position = pos


var animated_sprite : AnimatedSprite2D

func _start() -> Tween:
	if target == null:
		return null

	var animation_frames: SpriteFrames = load(path)
	var efferi:= AnimatedSprite2D.new()
	animated_sprite.sprite_frames = animation_frames
	animated_sprite.play(animation_name)
	animated_sprite.position = position
	target.add_child(animated_sprite)

	var looping = animation_frames.get_animation_loop_mode(animation_name) != SpriteFrames.LoopMode.LOOP_NONE

	if not looping:
		animated_sprite.animation_finished.connect(
		)
	elif looping && duration != -1:
		var tween := context.target.create_tween()
		tween.tween_interval(duration)

	return handle
	
func _cleanup(_cancelled: bool) -> void:
	animated_sprite.queue_free()
