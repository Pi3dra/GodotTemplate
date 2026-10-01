# meta-name: Interface
# meta-description: A template with all overridable functions of the interface class
# meta-space-indent: 4
extends Interface

#signal request_close(key: int)

func _ready() -> void:
	pass


func on_interface_shown() -> void:
	pass


func on_interface_hidden() -> void:
	pass


func on_interface_closing() -> void:
	pass

### CALLBACKS FOR OBSERVABLE UPDATES

func on_observable_changed(old_value, new_value, field_name: StringName) -> void:
	pass


func on_field_changed_array(old_value, new_value, key, behavior, array_name: StringName) -> void:
	pass


func on_field_changed_dict(old_value, new_value, key, behavior, dict_name: StringName) -> void:
	pass


func on_reset_array(array, array_name: StringName):
	pass


func on_reset_dict(array, array_name: StringName):
	pass
