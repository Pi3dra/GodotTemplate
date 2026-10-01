extends Resource
class_name SettingsData

#DISPLAY
@export var brightness : float = 1.
@export var contrast : float = 1.
@export var saturation : float = 1.
@export var shader: ShaderMaterial = null

#SOUND
@export var sfx : float = 1.
@export var music : float = 1.
@export var master : float = 1.

#Accesibility
@export var intensity : float = 1.
@export var font_size : float = 1.
@export var time_scale : float = 1.


@export var locale : String = "en"

# Action name -> Array[InputEvent]
@export var bindings: Dictionary = {}
