extends Node

var already_trained = false
var training = false
var current_tutorial = tutorial.TUTORIALS.Tavern

var cookies: Dictionary = { } #[Cookie.TYPE,CookieData]
var characters: Dictionary = { } #[LogicalCharacter.TYPE, CharacterData]


func _ready():
	cookies = load_resources("res://Resources/Cookies/")
	characters = load_resources("res://Resources/Characters/")
# Generic resource loader


# TODO sadly it seems  like type verification doesn't work for custom resources
func load_resources(path: String, expected_class: String = "Resource") -> Dictionary:
	var result: Dictionary = { }
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: %s" % path)
		return result

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource_path = path + file_name
			var res: Resource = ResourceLoader.load(resource_path)

			# Compare using class_name (from your Resource script)
			if res and res.is_class(expected_class):
				result[res.type] = res
			else:
				push_warning("%s is not a %s resource" % [resource_path, expected_class])
		file_name = dir.get_next()
	dir.list_dir_end()

	return result


func get_character_data(type: LogicalCharacter.TYPE) -> CharacterData:
	return characters.get(type)


func get_cookie_data(type: Cookie.TYPE) -> CookieData:
	return cookies.get(type)
