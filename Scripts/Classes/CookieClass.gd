class_name Cookie

enum TYPE {Normal, Berserk, Crit, Replay, Healing, Vampire, Weighted, Fast, Head}
enum EFFECTYPE {Chance, Combat}
enum STATE {Head, Tail, Unflipped}

var cookie_type : TYPE
var effect_type : EFFECTYPE
var state : STATE
var chance : int = 50

var tail_texture : AtlasTexture
var head_texture : AtlasTexture

var shadow_texture = preload("uid://kc4ef7j3bwdl")
var spritesheet = preload("uid://cu2f2lwoupqox")

func _init( pCookie_type):
	state = STATE.Unflipped
	cookie_type = pCookie_type
	var cookie_data : CookieData = Globals.get_cookie_data(pCookie_type)
	tail_texture = cookie_data.tails_texture
	head_texture = cookie_data.head_texture
	effect_type = cookie_data.effect

func to_stringg():
	var key_name = TYPE.keys()[cookie_type]
	return key_name
	
static func filter_cookies_type(cookie_list : Array, pCookie_type : TYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.cookie_type == pCookie_type )

static func filter_cookies_effect(cookie_list : Array, pCookie_effect :EFFECTYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.effect_type == pCookie_effect )

static func list_to_dict(cookie_list : Array[Cookie]) -> Dictionary:
	var dict = {}
	for value in TYPE.values():
		dict[value] = []
	for cookie in cookie_list:
		dict[cookie.cookie_type].append(cookie)
	return dict
	
## Returns an empty dict of type Dictionary[COOKIETYPE, Array[Cookie]
static func type_dict() -> Dictionary:
	var dict = {}
	for value in TYPE.values():
		dict[value] = []
	return dict

# Mon pire cauchemar
static func pick_random_special() -> Cookie.TYPE:
	var random = Cookie.TYPE.values().pick_random()
	if random == Cookie.TYPE.Normal:
		return pick_random_special()
	else:
		return random
