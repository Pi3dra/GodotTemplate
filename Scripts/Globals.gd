extends Node

var already_trained = false
var training = false
var current_tutorial = tutorial.TUTORIALS.Tavern


var cookies : Dictionary [Cookie.TYPE,CookieData] = {}

func _ready():
	load_cookies("res://Resources/Cookies/")

func load_cookies(path : String):
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("Could not open directory: %s" % path)
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var resource_path = path + "/" + file_name
			var cookie_res = ResourceLoader.load(resource_path)
			
			if cookie_res is CookieData:
				cookies[cookie_res.type] = cookie_res
			else:
				push_warning("%s is not a CookieData resource" % resource_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()


func get_cookie_data(type : Cookie.TYPE) -> CookieData:
	return cookies[type]
