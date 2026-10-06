extends Node
## Handles the storage and updatelh inside a [SettingsData] resource
##
## When the game is run for the first time, it reads the [InputMap] and [AudioBusLayout],
## and saves them as default settings under default_settings.tres [br]
## The remaining default settings can be tweaked in settinds_data.gd [br][br]
##
## Afterwards the user settings are saved, and re applied each time the game runs.
##
## To add a new configuration:[br]
## - Add a new entry to [enum Settings.OPTION] [br]
## - update method [method get_value] and [method set_value] accordingly [br]
## - Now you can update the settings from the UI and, [method save] them [br][br]
##
## The font size feature is @experimental I think it could be better
## The Display settings requires settings a screen based shader with: [method register_shader]

const DEBUG = true
enum OPTION { BRIGHTNESS, CONTRAST, SATURATION, SFX, MUSIC, MASTER, TIME_SCALE, FONT_SIZE, INTENSITY, LOCALE }

const SETTINGS_PATH := "user://saves/settings.tres"
const DEFAULT_PATH := "user://saves/default_settings.tres"
var data: SettingsData


func _ready():
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path("user://saves"),
	)

	var loaded := _try_load_settings()
	if loaded != null:
		data = loaded
		apply_all_settings()
	else:
		print("Loading Settings For First Time")
		data = SettingsData.new()
		_create_default_snapshot()


func _try_load_settings() -> SettingsData:
	if not ResourceLoader.exists(SETTINGS_PATH):
		return null
	var res := ResourceLoader.load(SETTINGS_PATH)
	return res as SettingsData # null if the load failed or the type is wrong


func save():
	ResourceSaver.save(data, SETTINGS_PATH)


## This should called by the root of the UI, to give acces to the shader overlay
## Without access to this shader, display settigns won't work
func register_shader(material: ShaderMaterial):
	data.shader = material
	set_option(OPTION.BRIGHTNESS, data.brightness)
	set_option(OPTION.CONTRAST, data.contrast)
	set_option(OPTION.SATURATION, data.saturation)


## Loads the default settings file and restores it
func reset_to_default(to_reset: Array[OPTION], all = false):
	var default_config = ResourceLoader.load(DEFAULT_PATH)
	var shader = data.shader
	if all:
		data = default_config.duplicate(true)
		data.shader = shader # This one has to be kept
		apply_all_settings()
	else:
		for option in to_reset:
			set_option(option, get_value(option))


## Applies all settings
## Settings must be defined in [enum OPTION]
## as well as in [method get_value] and [method set_value]
func apply_all_settings():
	for opt in OPTION.values():
		set_option(opt, get_value(opt))
	apply_bindings(data.bindings)


func get_value(opt: OPTION):
	match opt:
		OPTION.BRIGHTNESS:
			return data.brightness
		OPTION.CONTRAST:
			return data.contrast
		OPTION.SATURATION:
			return data.saturation
		OPTION.MUSIC:
			return data.music
		OPTION.SFX:
			return data.sfx
		OPTION.MASTER:
			return data.master
		OPTION.TIME_SCALE:
			return data.time_scale
		OPTION.FONT_SIZE:
			return data.font_size
		OPTION.INTENSITY:
			return data.intensity
		OPTION.LOCALE:
			return data.locale


func set_option(option: OPTION, value):
	if DEBUG:
		print("Updating settings ", option, " ", value)
	match option:
		#DISPLAY
		OPTION.BRIGHTNESS:
			data.brightness = value
			if data.shader:
				data.shader.set_shader_parameter("brightness", value)
		OPTION.CONTRAST:
			data.contrast = value
			if data.shader:
				data.shader.set_shader_parameter("contrast", value)
		OPTION.SATURATION:
			data.saturation = value
			if data.shader:
				data.shader.set_shader_parameter("saturation", value)
		#SOUND
		OPTION.MASTER:
			data.master = value
			set_bus_volume("Master", value)
		OPTION.SFX:
			data.sfx = value
			set_bus_volume("SFX", value)
		OPTION.MUSIC:
			data.music = value
			set_bus_volume("Music", value)
		#Accesibility
		OPTION.TIME_SCALE:
			data.time_scale = value
			Engine.time_scale = value
		OPTION.FONT_SIZE:
			data.font_size = value
			FontSize.set_global_font_scale(value)
		OPTION.INTENSITY:
			data.intensity = value
			#maybe emit a signal here?
		OPTION.LOCALE:
			data.locale = value
			TranslationServer.set_locale(value)


func set_bus_volume(bus_name: String, value: float) -> void:
	var bus = AudioServer.get_bus_index(bus_name)

	if value <= 0.0:
		AudioServer.set_bus_volume_db(bus, -80.0) # effectively silent
	else:
		AudioServer.set_bus_volume_db(
			bus,
			linear_to_db(value),
		)

#region FIRST TIME LOADING

## Runs when the user runs the game for the first time [br]
## - Loads the default configuration of audio buses [br]
## - Loads the default InputMap [br]
## Then saves this into a default save path
func _create_default_snapshot():
	_load_audio_buses()
	capture_bindings()
	ResourceSaver.save(data, DEFAULT_PATH)


## Loads the default bus configuration into data
func _load_audio_buses():
	var music_index := AudioServer.get_bus_index("Music")
	var music := db_to_linear(AudioServer.get_bus_volume_db(music_index))

	var sfx_index := AudioServer.get_bus_index("SFX")
	var sfx := db_to_linear(AudioServer.get_bus_volume_db(sfx_index))

	var master_index := AudioServer.get_bus_index("Master")
	var master := db_to_linear(AudioServer.get_bus_volume_db(master_index))

	data.music = music
	data.sfx = sfx
	data.master = master

#endregion

#region KEY BINDINGS
### Defines which actions are considered rebindable and are needed to save.
func _rebindable_actions() -> Array[StringName]:
	var result: Array[StringName] = []
	for action in InputMap.get_actions():
		if not String(action).begins_with("ui_"): # skip Godot's built-in UI actions
			result.append(action)
	return result


## Loads into the data all _rebindable_actions,
## by mapping action -> InnputEvent
func capture_bindings():
	data.bindings.clear()
	for action in _rebindable_actions():
		data.bindings[action] = _duplicate_events(InputMap.action_get_events(action))


### This is to avoid resources sharing, and being modified behing our back
### not sure this bug it will ever trigger, but at least we ensure it is an actual snapshot
func _duplicate_events(events: Array) -> Array:
	var out: Array = []
	for e in events:
		out.append(e.duplicate())
	return out


### Given a Dictionary(Action, InputEvent) of bindings,
### it updates the InputMap to use the new bindings
func apply_bindings(source: Dictionary):
	for action in source:
		if not InputMap.has_action(action):
			continue # action was removed in a newer version of the game
		InputMap.action_erase_events(action)
		for e in source[action]:
			InputMap.action_add_event(action, e.duplicate())
#endregion

#region FONT SIZE SCALING

@export var themes_folder: String = "res://Assets/Themes/"
var all_themes: Array[Theme] = []
var _base_sizes: Dictionary = { } # theme -> original default_font_size


### Recursively searches the themes under folder_path, so that
### the font can be later resized (this is hacky)
func _load_themes_folder(folder_path: String) -> Array[Theme]:
	var dir = DirAccess.open(folder_path)
	var themes: Array[Theme] = []

	if dir == null:
		push_warning("Could not open folder: " + folder_path)
		return themes

	for file_name in dir.get_files():
		if file_name.ends_with(".import"):
			continue
		if not (file_name.ends_with(".tres") or file_name.ends_with(".res")):
			continue

		var resource = load(folder_path.path_join(file_name))
		if resource is Theme:
			themes.append(resource)
		else:
			push_warning("Skipped non-Theme resource: " + file_name)

	for sub_folder in dir.get_directories():
		themes.append_array(_load_themes_folder(folder_path.path_join(sub_folder)))

	return themes


## Sets the font size of all themes under res://Assets/Themes
## @experimental
func set_global_font_scale(scale: float):
	for theme in all_themes:
		theme.set_default_font_size(_base_sizes[theme] * scale)

#endregion
