extends Interface

@onready var first_button = $"Save Settings"

#TODO BUT NOT SUPER IMPORTANT
# NAVIGATION WITH CONTROLLER ON THIS MENU IS REALLY BAD
# Doing dpad right or left on a slider changes value but blocks navigation
# To go back to the save button, one has to go back precisely to the right column
#
# Possible solutions
# Moving between sections with lb rb
# Saving with b to go back?


func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	first_button.grab_focus()
	_connect_buttons()

	$Sliders/Display/BrightnessSlider.value = Settings.brightness
	$Sliders/Display/ContrastSlider.value = Settings.contrast
	$Sliders/Display/SaturationSlider.value = Settings.saturation

	$Sliders/Audio/MasterSlider.value = Settings.master
	$Sliders/Audio/MusicSlider.value = Settings.music
	$Sliders/Audio/SFXSlider.value = Settings.sfx

	$Sliders/Accesibility/TimeSlider.value = Settings.time_scale
	$Sliders/Accesibility/FontSlider.value = Settings.font_size
	$Sliders/Accesibility/VFXSlider.value = Settings.intensity


func _on_save_settings_pressed() -> void:
	UI.manager.switch_ui(UIManager.UI.MAIN_MENU, false)

#region AUDIO

func _on_master_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.MASTER, value)


func _on_music_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.MUSIC, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.SFX, value)

#endregion

#region DISPLAY

func _on_brightness_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.BRIGHTNESS, value)


func _on_contrast_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.CONTRAST, value)


func _on_saturation_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.SATURATION, value)

#endregion

#region ACCESIBILITY

func _on_time_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.TIME_SCALE, value)


func _on_font_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.FONT_SIZE, value)


func _on_vfx_slider_value_changed(value: float) -> void:
	Settings.set_float(Settings.OPTION.INTENSITY, value)

#endregion

#region LANGUAGE

# https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html

func _on_en_pressed() -> void:
	TranslationServer.set_locale("en")


func _on_fr_pressed() -> void:
	TranslationServer.set_locale("fr")


func _on_sp_pressed() -> void:
	TranslationServer.set_locale("es")

#endregion

#region KEY BINDINGS

#TODO ADVANCED Add a save feature
#TODO ADVANCED if local-co op support both keyboard and controller?
#TODO Make it work with the mouse as well
#TODO Probably move this to either the settings global or elsewhere

#HOW TO ADD BUTTONS
#  1.First go to Project > Project Settings > Input Map
#  2.Add a new input map, with the keys you want
#  3.Add a button under the Inputs node which has exactly the same name as your Input Map

var waiting_for_action: StringName = ""
var waiting_button: Button = null

## Maps a human-readable binding text -> action name (used for reuse checks)
var mappings: Dictionary[String, String] = { }

## Tracks which joypad axes are currently "pushed" past the deadzone,
## so motion events only trigger once per push instead of every frame.
var _active_axes: Dictionary = { }

@onready var button_atlas: AtlasTexture = load("res://Scenes/UI/button_textures.tres")
var button_size := Vector2i(16, 16)

const AXIS_DEADZONE := 0.5

# Map (axis, direction) -> column offset (in units of button_size.x)
const AXIS_OFFSETS := {
	JOY_AXIS_LEFT_X: { "neg": 3, "pos": 1 },
	JOY_AXIS_LEFT_Y: { "neg": 0, "pos": 2 },
	JOY_AXIS_RIGHT_X: { "neg": 3, "pos": 1 },
	JOY_AXIS_RIGHT_Y: { "neg": 0, "pos": 2 },
	JOY_AXIS_TRIGGER_LEFT: { "neg": 0, "pos": 0 },
	JOY_AXIS_TRIGGER_RIGHT: { "neg": 0, "pos": 1 },
}


# Removes an used key/button before rebinding
func _clear_joypad_bindings(action: StringName):
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton or e is InputEventJoypadMotion:
			InputMap.action_erase_event(action, e)


func _connect_buttons():
	for child in $Controllers/Languages2/Inputs.get_children():
		if child is Button:
			child.pressed.connect(_rebind_pressed.bind(child))
	_refresh_all_bindings()


# Detects if a joypad has been connected/disconnected
func _on_joy_connection_changed(_device: int, _connected: bool):
	_refresh_all_bindings()


func _refresh_all_bindings():
	for child in $Controllers/Languages2/Inputs.get_children():
		if child is Button and not waiting_for_action == child.name:
			_update_button_display(child)


# Updates all bindings to match either the joypad or keyboard display
func _update_button_display(button: Button):
	var action: StringName = button.name

	if Input.get_connected_joypads().size() > 0:
		var icon = _get_action_joypad_icon(action)
		if icon != null:
			button.text = ""
			button.icon = icon
			button.custom_minimum_size = Vector2(64, 64)
			button.expand_icon = true
			button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			mappings[icon.resource_name] = action
			return

	# No controller, or no joypad binding for this action -> show keyboard text
	button.icon = null
	var key_text = _get_binding_text(action)
	button.text = key_text
	mappings[key_text] = action


func check_reuse(event) -> bool:
	return mappings.keys().has(event.as_text())


func _rebind_pressed(button: Button):
	waiting_button = button
	waiting_for_action = button.name
	if Input.get_connected_joypads().size() > 0:
		button.icon = null
		button.text = "Press a button..."
	else:
		button.text = "Press a key..."


# Returns the first character or word from an action
# "Tab - Physical" returns "Tab"
func _get_binding_text(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			var text = event.as_text()
			var space_idx = text.find(" ")
			if space_idx != -1:
				text = text.substr(0, space_idx)
			return text
	return "Unbound"


func _get_action_joypad_icon(action: StringName) -> AtlasTexture:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton:
			return get_joypad_icon(event)
		if event is InputEventJoypadMotion:
			return get_joypad_icon(event)
	return null


func _input(event):
	if not waiting_for_action.is_empty():
		_handle_rebind(event)
		return

	# Not rebinding: just keep the axis-active tracking sane so the
	# next rebind attempt starts from a clean edge state.
	if event is InputEventJoypadMotion:
		_track_axis_state(event)


func _handle_rebind(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if check_reuse(event):
			_update_button_display(waiting_button)
			waiting_for_action = ""
			waiting_button = null
			return

		for e in InputMap.action_get_events(waiting_for_action):
			if e is InputEventKey:
				InputMap.action_erase_event(waiting_for_action, e)
		InputMap.action_add_event(waiting_for_action, event)

		_finish_rebind()
		get_viewport().set_input_as_handled()

	elif event is InputEventJoypadButton and event.pressed:
		if check_reuse(event):
			_update_button_display(waiting_button)
			waiting_for_action = ""
			waiting_button = null
			return

		_clear_joypad_bindings(waiting_for_action)
		InputMap.action_add_event(waiting_for_action, event)

		_finish_rebind()
		get_viewport().set_input_as_handled()

	elif event is InputEventJoypadMotion:
		var just_activated = _track_axis_state(event)
		if not just_activated:
			return # still in deadzone, or already active -> ignore

		if check_reuse(event):
			_update_button_display(waiting_button)
			waiting_for_action = ""
			waiting_button = null
			return

		_clear_joypad_bindings(waiting_for_action)
		InputMap.action_add_event(waiting_for_action, event)

		_finish_rebind()
		get_viewport().set_input_as_handled()


func _finish_rebind():
	_update_button_display(waiting_button)
	waiting_for_action = ""
	waiting_button = null


## Returns true only on the transition from "released" to "pushed past deadzone".
## Keeps a per-(device, axis, sign) flag so holding the stick doesn't retrigger.
func _track_axis_state(event: InputEventJoypadMotion) -> bool:
	var key = "%d_%d" % [event.device, event.axis]
	var over_threshold = absf(event.axis_value) >= AXIS_DEADZONE

	if not over_threshold:
		_active_axes[key] = false
		return false

	if _active_axes.get(key, false):
		return false # already active, this is just a held stick

	_active_axes[key] = true
	return true


func get_joypad_icon(event) -> AtlasTexture:
	var icon = AtlasTexture.new()
	icon.atlas = button_atlas

	if event is InputEventJoypadButton:
		var idx: int = event.button_index
		icon.region = Rect2i(Vector2i(idx * button_size.x, 0), button_size)
		icon.resource_name = event.as_text()
		return icon

	if event is InputEventJoypadMotion:
		if absf(event.axis_value) < AXIS_DEADZONE:
			return null

		var l_joystick_pos = Vector2i(4 * button_size.x, 1 * button_size.y)
		var r_joystick_pos = Vector2i(8 * button_size.x, 1 * button_size.y)
		var triggers_pos = Vector2i(12 * button_size.x, 1 * button_size.y)
		var offset = _get_axis_offset(event.axis, event.axis_value)
		var rect: Rect2i

		match event.axis:
			JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
				l_joystick_pos.x += offset * button_size.x
				rect = Rect2i(l_joystick_pos, button_size)
			JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
				r_joystick_pos.x += offset * button_size.x
				rect = Rect2i(r_joystick_pos, button_size)
			JOY_AXIS_TRIGGER_LEFT, JOY_AXIS_TRIGGER_RIGHT:
				triggers_pos.x += offset * button_size.x
				rect = Rect2i(triggers_pos, button_size)
			_:
				return null

		icon.region = rect
		icon.resource_name = event.as_text()
		return icon

	return null


func _get_axis_offset(axis: int, value: float) -> int:
	if not AXIS_OFFSETS.has(axis):
		return 0

	var dirs = AXIS_OFFSETS[axis]
	if value < -0.5:
		return dirs["neg"]
	elif value > 0.5:
		return dirs["pos"]
	return 0

#endregion
