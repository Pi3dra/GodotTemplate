class_name Cookie

enum TYPE { NORMAL, CRIT, REPLAY, VAMPIRE, WEIGHTED, FAST }
enum EFFECTYPE { CHANCE, COMBAT }
enum STATE { HEAD, TAIL, UNFLIPPED }

var cookie_type: TYPE
var effect_type: EFFECTYPE
var state: STATE
var chance: int = 50

var tail_texture: AtlasTexture
var head_texture: AtlasTexture

var shadow_texture = preload("uid://kc4ef7j3bwdl")
var spritesheet = preload("uid://cu2f2lwoupqox")


#TODO: Check if this is ok? seems like pCookie is copiying to prevent bugs
func _init(pCookie_type):
	state = STATE.UNFLIPPED
	cookie_type = pCookie_type
	var cookie_data: CookieData = Globals.get_cookie_data(pCookie_type)
	tail_texture = cookie_data.tails_texture
	head_texture = cookie_data.head_texture
	effect_type = cookie_data.effect


func to_stringg():
	var key_name = TYPE.keys()[cookie_type]
	return key_name


static func filter_cookies_type(cookie_list: Array, type: TYPE) -> Array:
	return cookie_list.filter(func(cookie): return cookie.cookie_type == type)


static func filter_cookies_effect(cookie_list: Array, effect: EFFECTYPE) -> Array:
	return cookie_list.filter(func(cookie): return cookie.effect_type == effect)


static func list_to_dict(cookie_list: Array[Cookie]) -> Dictionary:
	var dict = { }
	for value in TYPE.values():
		dict[value] = []
	for cookie in cookie_list:
		dict[cookie.cookie_type].append(cookie)
	return dict


## Returns an empty dict of type Dictionary[COOKIETYPE, Array[Cookie]
static func type_dict() -> Dictionary:
	var dict = { }
	for value in TYPE.values():
		dict[value] = []
	return dict


# Mon pire cauchemar
static func pick_random_special() -> Cookie.TYPE:
	var choices: Array = Cookie.TYPE.values() #.pick_random()
	choices.erase(Cookie.TYPE.NORMAL)
	return choices.pick_random()
