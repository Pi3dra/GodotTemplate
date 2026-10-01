class_name SoundEffect
extends Effect

var sound_name: StringName
var volume_db: float
var pitch: float
var loop: bool
var duration: float
var _player: Node


func _init(p_sound_name, p_volume_db := 0.0, p_pitch := 1.0, p_loop := false, p_duration := -1.0) -> void:
	sound_name = p_sound_name
	volume_db = p_volume_db
	pitch = p_pitch
	loop = p_loop
	duration = p_duration


func _start() -> Tween:
	if target == null:
		return null

	_player = SoundManager.play(sound_name, volume_db, pitch, loop)
	if not loop:
		_player.finished.connect(_finish, CONNECT_ONE_SHOT)

	if duration < 0:
		return null # fire and forget: the effect ends now, the sound keeps playing

	var tween := target.create_tween()
	tween.tween_interval(duration)
	return tween


func _cleanup(_cancelled: bool) -> void:
	if not is_instance_valid(_player):
		return
	if _player.finished.is_connected(_finish):
		_player.finished.disconnect(_finish)
	if duration >= 0:
		_player.stop() # timed sounds are stopped when the effect ends
