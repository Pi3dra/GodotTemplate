extends Effect
class_name SoundEffect

#Stream players can also do effects like ramp up fade in out etc, pitch shift, panning, ducking check out audioeffectfilter

var sound_name
var volume_db
var pitch 
var loop
var duration

func _init(
	p_sound_name,
	p_volume_db ,
	p_pitch ,
	p_loop ,
	p_duration,
) -> void:
	sound_name = p_sound_name
	volume_db = p_volume_db 
	pitch = p_pitch 
	loop = p_loop 
	duration = p_duration


func execute(context: EffectContext) -> EffectHandle:
	var target := context.target
	var handle := EffectHandle.new()

	if target == null:
		handle.complete()
		return handle
		
	var player = SoundManager.play(sound_name, volume_db, pitch, loop)
	
	if not loop:
		player.finished.connect(handle.complete)
	if duration > -1:
		var tween := context.target.create_tween()
		tween.tween_interval(duration)
		tween.finished.connect(
			func():
				handle.complete()
				player.stop()
		)
	else:
		handle.complete()

	return handle
