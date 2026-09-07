extends Node

## This is a Global State Script
## 
## Consider splitting this into multiple singletons
## If you need more local data sets
##
## Rules for adding variables here
## - Variables should be needed through multiple tscenes/interfaces
## - i.e Settings, Persistent player and world data, global constants
## - variables that get modified in a predictable manner i.e gold might be spent only in shops, but shown in multiple UIs
##
## Rules for adding functions here:
## - Functions that alter global state in a specific way, better if used in multiples scripts
## - Functions that compute data based on global state, only if small and used in multiple scripts
##
## Remember you can hide variables like so
## var _myvar : int = 5
##
## And make them constant with:
## const  MYCONSTANT : int = 5

const DEBUG = false
enum OPTION {BRIGHTNESS, CONTRAST, SATURATION, SFX, MUSIC, MASTER,TIME_SCALE, FONT_SIZE, INTENSITY}

#DISPLAY
var brightness : float = 1.
var contrast : float = 1.
var saturation : float = 1.
var shader: ShaderMaterial = null

#SOUND
var sfx : float = 1.
var music : float = 1.
var master : float = 1.

#Accesibility
var intensity : float = 1.
var font_size : float = 1.
var time_scale : float = 1.

func register_shader(material: ShaderMaterial):
	shader = material
	shader.set_shader_parameter("brightness", brightness)

func set_float(option : OPTION, value : float):
	if DEBUG:
		print("Updating settings",option,value)
	if shader:
		match option:
			#DISPLAY
			OPTION.BRIGHTNESS:
				brightness = value
				shader.set_shader_parameter("brightness", brightness)
			OPTION.CONTRAST:
				contrast = value
				shader.set_shader_parameter("contrast", contrast)
			OPTION.SATURATION:
				saturation = value
				shader.set_shader_parameter("saturation", saturation)
			#SOUND
			OPTION.MASTER:
				master = value
				set_bus_volume("Master", master)
			OPTION.SFX:
				sfx = value
				set_bus_volume("SFX", sfx)
			OPTION.MUSIC:
				music = value
				set_bus_volume("Music", music)
			
			#Accesibility
			OPTION.TIME_SCALE:
				time_scale = value
				Engine.time_scale = time_scale
				
			OPTION.FONT_SIZE:
				font_size = value
				FontSize.set_global_font_scale(value)
			
			OPTION.INTENSITY:
				intensity = value
				#maybe emit a signal here? 


func set_bus_volume(bus_name: String, value: float) -> void:
	var bus = AudioServer.get_bus_index(bus_name)

	if value <= 0.0:
		AudioServer.set_bus_volume_db(bus, -80.0) # effectively silent
	else:
		AudioServer.set_bus_volume_db(
			bus,
			linear_to_db(value)
		)
		

@export var themes_folder: String = "res://Assets/Themes/"

var all_themes: Array[Theme] = []
var _base_sizes: Dictionary = {}  # theme -> original default_font_size

func _ready():
	all_themes = _load_themes_folder(themes_folder)
	for theme in all_themes:
		_base_sizes[theme] = theme.default_font_size

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


func set_global_font_scale(scale: float):
	for theme in all_themes:
		var fsize = theme.get_default_font_size()
		theme.set_default_font_size(fsize*scale)
		
