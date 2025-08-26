class_name Cookie

enum EFFECTYPE {Chance, Combat}
enum SCREENSIDE {Head, Tail}
enum STATE {Head, Tail, Unflipped}

var id
var description
var cookie_type : Globals.COOKIETYPE
var effect_type : EFFECTYPE
var side : SCREENSIDE
var state : STATE
var chance : int = 50

var tail_texture : AtlasTexture
var head_texture : AtlasTexture
var shadow_texture = preload("res://Assets/Sprites/cookie_shadow.png")
var spritesheet = preload("res://Assets/Sprites/CookieSheet.png")

func _init(pId, pDescription, pCookie_type):
	id = pId
	description = pDescription
	cookie_type = pCookie_type
	
	var head_atlas = AtlasTexture.new()
	head_atlas.atlas = spritesheet
	head_atlas.region = Rect2(0, cookie_type * 32, 32, 32)
	
	var tail_atlas = AtlasTexture.new()
	tail_atlas.atlas = spritesheet
	tail_atlas.region = Rect2(32, cookie_type * 32, 32, 32)
	
	tail_texture = tail_atlas
	head_texture = head_atlas
	
	if  cookie_type == Globals.COOKIETYPE.Weighted:
		effect_type = EFFECTYPE.Chance
	else:
		effect_type = EFFECTYPE.Combat

func to_stringg():
	var key_name = Globals.COOKIETYPE.keys()[cookie_type]
	return key_name
	
static func filter_cookies_type(cookie_list : Array, pCookie_type : Globals.COOKIETYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.cookie_type == pCookie_type )

static func filter_cookies_effect(cookie_list : Array, pCookie_effect :EFFECTYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.effect_type == pCookie_effect )


static func list_to_dict(cookie_list : Array[Cookie]) -> Dictionary:
	print("Adding:", cookie_list)
	var dict = {}
	for value in Globals.COOKIETYPE.values():
		dict[value] = []
	for cookie in cookie_list:
		dict[cookie.cookie_type].append(cookie)
	print("Result:", dict)
	return dict
	
## Returns an empty dict of type Dictionary[COOKIETYPE, Array[Cookie]
static func type_dict() -> Dictionary:
	var dict = {}
	for value in Globals.COOKIETYPE.values():
		dict[value] = []
	return dict
	
#TODO: Might be good to have a function that returns the sprite of a given cookie type
