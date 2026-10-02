extends Interface

@onready var first_button = $"Save Settings"


func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	first_button.grab_focus()
	_connect_buttons()

	_refresh_sliders()

	rebinder.finished_rebinding.connect(_on_finished_rebinding)
	rebinder.rebind_collision.connect(_on_rebind_collision)


func _refresh_sliders():
	$Sliders/Display/BrightnessSlider.value = Settings.data.brightness
	$Sliders/Display/ContrastSlider.value = Settings.data.contrast
	$Sliders/Display/SaturationSlider.value = Settings.data.saturation

	$Sliders/Audio/MasterSlider.value = Settings.data.master
	$Sliders/Audio/MusicSlider.value = Settings.data.music
	$Sliders/Audio/SFXSlider.value = Settings.data.sfx

	$Sliders/Accesibility/TimeSlider.value = Settings.data.time_scale
	$Sliders/Accesibility/FontSlider.value = Settings.data.font_size
	$Sliders/Accesibility/VFXSlider.value = Settings.data.intensity


func _on_save_settings_pressed() -> void:
	Settings.save()
	UIManager.switch_ui(UIManager.UI.MAIN_MENU)

#region AUDIO

func _on_master_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.MASTER, value)


func _on_music_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.MUSIC, value)


func _on_sfx_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.SFX, value)

#endregion

#region DISPLAY

func _on_brightness_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.BRIGHTNESS, value)


func _on_contrast_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.CONTRAST, value)


func _on_saturation_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.SATURATION, value)

#endregion

#region ACCESIBILITY

func _on_time_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.TIME_SCALE, value)


func _on_font_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.FONT_SIZE, value)


func _on_vfx_slider_value_changed(value: float) -> void:
	Settings.set_option(Settings.OPTION.INTENSITY, value)

#endregion

#region LANGUAGE

# https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html

func _on_en_pressed() -> void:
	Settings.set_option(Settings.OPTION.LOCALE, "en")


func _on_fr_pressed() -> void:
	Settings.set_option(Settings.OPTION.LOCALE, "fr")


func _on_sp_pressed() -> void:
	Settings.set_option(Settings.OPTION.LOCALE, "es")

#endregion

#region KEY BINDINGS

# HOW TO ADD A REBINDABLE ACTION
#  1. Project > Project Settings > Input Map: add the action with its default keys.
#  2. Add a Button under the Inputs node whose NAME is exactly the action name.
#  The name match in step 2 is essential: the button's name is used as the action.

## Button the player clicked to start the rebind (so we can update its display).
var waiting_button: Button = null
var rebinder: InputRebinder = InputRebinder.new()
@onready var keybind_buttons = $Controllers/KeyBinds/Inputs.get_children()

#region BUTTON DISPLAY

@onready var button_atlas: AtlasTexture = load("uid://chch3niwr6wfn")
var button_size := Vector2i(16, 16)

## Atlas column where each axis group starts in the second row.
const AXIS_BASE_COLUMN := {
	JOY_AXIS_LEFT_X: 4,
	JOY_AXIS_LEFT_Y: 4,
	JOY_AXIS_RIGHT_X: 8,
	JOY_AXIS_RIGHT_Y: 8,
	JOY_AXIS_TRIGGER_LEFT: 12,
	JOY_AXIS_TRIGGER_RIGHT: 12,
}


## Builds an AtlasTexture icon for a joypad button or axis event.
func get_joypad_icon(event: InputEvent) -> AtlasTexture:
	var cell: Vector2i # (column, row) in the atlas

	if event is InputEventJoypadButton:
		cell = Vector2i(event.button_index, 0)
	elif event is InputEventJoypadMotion and AXIS_BASE_COLUMN.has(event.axis):
		if absf(event.axis_value) < rebinder.AXIS_DEADZONE:
			return null
		var column: int = AXIS_BASE_COLUMN[event.axis] + rebinder.get_axis_offset(event.axis, event.axis_value)
		cell = Vector2i(column, 1)
	else:
		return null

	var icon := AtlasTexture.new()
	icon.atlas = button_atlas
	icon.region = Rect2i(cell * Vector2i(button_size), Vector2i(button_size))
	return icon


## Hooks up every rebind button and draws their initial display.
## Hooks up every rebind button and draws their initial display.
func _connect_buttons() -> void:
	for child in keybind_buttons:
		if child is Button:
			child.pressed.connect(_rebind_pressed.bind(child))
			child.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
			# Icon layout never changes, so set it once here.
			child.custom_minimum_size = Vector2(64, 64)
			child.expand_icon = true
			child.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_refresh_all_bindings()


func _rebind_pressed(button: Button) -> void:
	waiting_button = button
	rebinder.rebind_pressed(button)
	button.icon = null
	button.text = "Press a button..." if _has_joypad() else "Press a key..."


func _input(event: InputEvent) -> void:
	if not rebinder.waiting_for_action.is_empty():
		rebinder.handle_rebind(event)
		get_viewport().set_input_as_handled()
		return

	# Not rebinding: keep axis tracking up to date so the next rebind
	# attempt starts from a clean state.
	if event is InputEventJoypadMotion:
		rebinder.track_axis_state(event)


## Called when a joypad is plugged in or removed (keyboard text <-> icons).
func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_refresh_all_bindings()


## Redraws every button, except the one currently waiting for input.
func _refresh_all_bindings() -> void:
	for child in keybind_buttons:
		if child is Button and rebinder.waiting_for_action != child.name:
			_update_button_display(child)


## Joypad icon if a controller is connected and the action has a joypad
## binding, otherwise the keyboard key as text.
func _update_button_display(button: Button) -> void:
	var action: StringName = button.name
	var icon := _get_action_joypad_icon(action) if _has_joypad() else null

	button.icon = icon
	button.text = "" if icon else _get_binding_text(action)


func _has_joypad() -> bool:
	return not Input.get_connected_joypads().is_empty()


## First keyboard binding as short text, e.g. "Tab - Physical" -> "Tab".
func _get_binding_text(action: StringName) -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.as_text().get_slice(" ", 0)
	return "Unbound"


## Icon for the action's first usable joypad binding, or null if none.
func _get_action_joypad_icon(action: StringName) -> AtlasTexture:
	for event in InputMap.action_get_events(action):
		var icon := get_joypad_icon(event)
		if icon != null:
			return icon
	return null


func _on_finished_rebinding():
	_update_button_display(waiting_button)
#endregion

@onready var collision_label = $Controllers/CollisionLabel
var previous_effect


func _on_rebind_collision(this, collides_with):
	collision_label.modulate.a = 1
	if previous_effect:
		previous_effect.kill()
	collision_label.text = this.as_text().get_slice(" ", 0) + " Is already in use by " + collides_with

	var effect = Effect.fade(4., true).play(collision_label)
	previous_effect = effect
	effect.on_finished(
		func():
			collision_label.text = ""
	)


func _on_reset_to_default_pressed() -> void:
	print("Pressed restart")
	Settings.reset_to_default([], true)
	_refresh_all_bindings()
	_refresh_sliders()
