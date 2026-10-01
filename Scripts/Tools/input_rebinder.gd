extends Resource

class_name InputRebinder

## Emitted when the pressed input is already bound to another action.
## `this` is the action being rebound, `collides_with` is the action that owns the input.
signal rebind_collision(this: StringName, collides_with: StringName)
signal finished_rebinding()

## Action currently waiting for a new input ("" when not rebinding).
var waiting_for_action: StringName = ""

## Maps displayed binding text -> action name. Used to detect duplicate bindings.
var mappings: Dictionary[String, String] = { }

## Tracks which joypad axes are currently pushed past the deadzone, so a stick
## push triggers once instead of every frame. Key is "device_axis".
var _active_axes: Dictionary = { }

const AXIS_DEADZONE := 0.5
## Atlas column offset (in units of button_size.x) for each axis direction.
## "neg" = stick pushed left/up, "pos" = stick pushed right/down.
const AXIS_OFFSETS := {
	JOY_AXIS_LEFT_X: { "neg": 3, "pos": 1 },
	JOY_AXIS_LEFT_Y: { "neg": 0, "pos": 2 },
	JOY_AXIS_RIGHT_X: { "neg": 3, "pos": 1 },
	JOY_AXIS_RIGHT_Y: { "neg": 0, "pos": 2 },
	JOY_AXIS_TRIGGER_LEFT: { "neg": 0, "pos": 0 },
	JOY_AXIS_TRIGGER_RIGHT: { "neg": 0, "pos": 1 },
}

# ---------------------------------------------------------------------------
# Rebinding flow
# ---------------------------------------------------------------------------


## Returns the name of another action that already uses this input, or "" if free.
func find_collision(event: InputEvent) -> StringName:
	for action in InputMap.get_actions():
		if action == waiting_for_action or action.begins_with("ui_"):
			continue # rebinding to what it already has isn't a collision
		if InputMap.action_has_event(action, event):
			return action
	return &""


## A rebind button was clicked: start listening for the next input.
func rebind_pressed(button: Button) -> void:
	waiting_for_action = button.name


## Decides whether the event is a valid new binding, then applies it.
func handle_rebind(event: InputEvent) -> void:
	var is_key = event is InputEventKey and event.pressed and not event.echo
	var is_button = event is InputEventJoypadButton and event.pressed
	var is_axis := event is InputEventJoypadMotion and track_axis_state(event)

	if not (is_key or is_button or is_axis):
		return

	var collides_with := find_collision(event)
	if collides_with != &"":
		var this := waiting_for_action # grab it before cancel clears it
		_cancel_rebind()
		rebind_collision.emit(event, collides_with)
		return

	if is_key:
		_clear_key_bindings(waiting_for_action)
	else:
		_clear_joypad_bindings(waiting_for_action)

	InputMap.action_add_event(waiting_for_action, event)
	_finish_rebind()


## Removes existing keyboard events from an action before rebinding.
func _clear_key_bindings(action: StringName) -> void:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			InputMap.action_erase_event(action, e)


## Removes existing joypad button/axis events from an action before rebinding.
func _clear_joypad_bindings(action: StringName) -> void:
	for e in InputMap.action_get_events(action):
		if e is InputEventJoypadButton or e is InputEventJoypadMotion:
			InputMap.action_erase_event(action, e)


## Rebind succeeded: refresh the button and stop listening.
func _finish_rebind() -> void:
	#_update_button_display(waiting_button)
	_stop_waiting()
	finished_rebinding.emit()
	Settings.capture_bindings()


## Rebind cancelled: restore the button's previous display and stop listening.
func _cancel_rebind() -> void:
	#_update_button_display(waiting_button)
	finished_rebinding.emit()
	_stop_waiting()


func _stop_waiting() -> void:
	waiting_for_action = ""

# ---------------------------------------------------------------------------
# Joypad axis helpers
# ---------------------------------------------------------------------------


## Returns true only on the transition from "released" to "pushed past deadzone".
## Holding the stick does not retrigger. State is tracked per (device, axis).
func track_axis_state(event: InputEventJoypadMotion) -> bool:
	var key := "%d_%d" % [event.device, event.axis]
	var over_threshold := absf(event.axis_value) >= AXIS_DEADZONE

	if not over_threshold:
		_active_axes[key] = false
		return false

	if _active_axes.get(key, false):
		return false # already active: the stick is just being held

	_active_axes[key] = true
	return true


## Returns the atlas column offset for an axis and push direction (0 if unknown).
func get_axis_offset(axis: int, value: float) -> int:
	if not AXIS_OFFSETS.has(axis):
		return 0

	var dirs: Dictionary = AXIS_OFFSETS[axis]
	if value < -AXIS_DEADZONE:
		return dirs["neg"]
	elif value > AXIS_DEADZONE:
		return dirs["pos"]
	return 0
