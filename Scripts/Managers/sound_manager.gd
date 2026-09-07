class_name SoundManager
extends Node

#TODO ADVANCED adapt this for spatial sound
#TODO Make settings load default bus config!

static var instance: SoundManager

@export var total_pool_size: int = 16 # total concurrent voices, shared across all sounds
@export var default_max_polyphony: int = 8 # hard cap per sound unless SoundData overrides it

var sound_library: Dictionary = { } # name -> SoundData
var _pool: Array[AudioStreamPlayer] = []

var active_players: Array[AudioStreamPlayer] = []
var _active_counts: Dictionary = { } # name -> int (currently playing)
var _paused: bool = false


func _ready():
	if instance != null:
		push_warning("Multiple SoundManager instances detected, freeing duplicate.")
		queue_free()
		return
	instance = self

	_load_resources()
	_build_pool()

#region LOADING SOUNDS

func _load_resources():
	sound_library.clear()
	_active_counts.clear()

	_load_folder("res://Assets/Audio/Music", "Music")
	_load_folder("res://Assets/Audio/SFX", "SFX")


func _load_folder(folder_name: String, bus: String):
	var files := ResourceLoader.list_directory(folder_name)

	if files.is_empty():
		push_warning("No resources found in: " + folder_name)
		return

	for file_name in files:
		if file_name == "." or file_name == "..":
			continue

		# Ignore metadata
		if file_name.ends_with(".import"):
			continue

		# Only load audio files
		var extension := file_name.get_extension().to_lower()
		if extension not in ["ogg", "mp3", "wav"]:
			continue

		var path := folder_name.path_join(file_name)

		var stream := load(path)

		if stream == null:
			push_warning("Could not load audio resource: " + path)
			continue

		if not stream is AudioStream:
			continue

		var data := SoundData.new()
		data.name = file_name.get_basename()
		data.stream = stream
		data.bus = bus

		sound_library[data.name] = data
		_active_counts[data.name] = 0

#endregion

#region POOLING

func _build_pool():
	for i in total_pool_size:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)


func _get_free_player() -> AudioStreamPlayer:
	for player in _pool:
		if not player.playing:
			return player
	# Pool exhausted: steal the first one rather than growing unboundedly.
	# (Simple heuristic: not a true LRU, but fine for most SFX use cases.)
	return _pool[0]


func _on_player_finished(player: AudioStreamPlayer, sound_name: String):
	active_players.erase(player)
	_active_counts[sound_name] = max(0, _active_counts.get(sound_name, 0) - 1)
	# Player is NOT freed -- it belongs to the shared pool and gets reused.

#endregion

func play(
	sound_name: String,
	volume_db := 0.0,
	pitch := 1.0,
	loop := false
) -> AudioStreamPlayer:
	if not sound_library.has(sound_name):
		push_warning("Sound not found: " + sound_name)
		return null

	var data: SoundData = sound_library[sound_name]

	var max_poly = data.max_polyphony if "max_polyphony" in data and data.max_polyphony > 0 else default_max_polyphony
	if _active_counts.get(sound_name, 0) >= max_poly:
		return null

	var player := _get_free_player()

	if player.playing:
		var previous_sound: String = player.get_meta("sound_name", "")
		player.stop()

		if previous_sound != "":
			_on_player_finished(player, previous_sound)

	player.stream = data.stream
	player.bus = data.bus
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.set_meta("sound_name", sound_name)

	if player.stream is AudioStreamOggVorbis:
		player.stream.loop = loop
	elif player.stream is AudioStreamMP3:
		player.stream.loop = loop
	elif player.stream is AudioStreamWAV:
		player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
		
	if not active_players.has(player):
		active_players.append(player)

	_active_counts[sound_name] = _active_counts.get(sound_name, 0) + 1

	if player.finished.is_connected(_on_player_finished):
		player.finished.disconnect(_on_player_finished)

	player.finished.connect(
		_on_player_finished.bind(player, sound_name),
		CONNECT_ONE_SHOT
	)

	player.play()

	return player

func play_random_pitch(sound_name: String, min_pitch := 0.8, max_pitch := 1.2) -> AudioStreamPlayer:
	return play(sound_name, 0.0, randf_range(min_pitch, max_pitch))


func stop_all():
	# Iterate a copy since _on_player_finished mutates active_players,
	# and stop() does not emit 'finished' so this alone wouldn't self-correct.
	for player in active_players.duplicate():
		player.stop()
	active_players.clear()
	for key in _active_counts.keys():
		_active_counts[key] = 0


func pause_all():
	if _paused:
		return
	_paused = true
	for player in active_players:
		player.stream_paused = true


func resume_all():
	if not _paused:
		return
	_paused = false
	for player in active_players:
		player.stream_paused = false
