class_name SoundEffect
extends Effect

var sound_name: StringName
var volume_db: float
var pitch: float
var loop: bool
var duration: float # negative = no time limit


func _init(
		p_sound_name: StringName = &"",
		p_volume_db := 0.0,
		p_pitch := 1.0,
		p_loop := false,
		p_duration := -1.0,
) -> void:
	sound_name = p_sound_name
	volume_db = p_volume_db
	pitch = p_pitch
	loop = p_loop
	duration = p_duration


func _begin(run: EffectContext) -> void:
	if run.target == null:
		run.finish()
		return

	var player := SoundManager.play(sound_name, volume_db, pitch, loop)
	if player == null:
		run.finish()
		return
	run.data.player = player # needed later by _cleanup and pause

	# A one-shot sound ends the run when it finishes.
	if not loop:
		run.finish_on_signal(player.finished)

	# Optional time limit: cuts a loop, or caps a long sound. First one wins.
	if duration >= 0.0:
		run.finish_after(duration)

	# loop with duration < 0 plays until cancelled, by design.


func _cleanup(run: EffectContext, cancelled: bool) -> void:
	var player := run.data.get("player") as Node
	if not is_instance_valid(player):
		return

	# Stop if the run ended because of a time limit or a cancel.
	# A one-shot sound that ended by itself is already finished.
	if cancelled or loop or duration >= 0.0:
		player.stop()


func _on_pause(run: EffectContext) -> void:
	var player = run.data.get("player")
	if is_instance_valid(player):
		player.stream_paused = true


func _on_resume(run: EffectContext) -> void:
	var player = run.data.get("player")
	if is_instance_valid(player):
		player.stream_paused = false
