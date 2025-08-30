class_name Cookie

enum TYPE {Normal, Berserk, Crit, Golden, Replay, Healing, Vampire, Weighted, Fast, Head, Tail}
enum EFFECTYPE {Chance, Combat}
enum SCREENSIDE {Head, Tail}
enum STATE {Head, Tail, Unflipped}

var id
var description
var cookie_type : TYPE
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
	
	if  cookie_type == TYPE.Weighted:
		effect_type = EFFECTYPE.Chance
	else:
		effect_type = EFFECTYPE.Combat

func to_stringg():
	var key_name = TYPE.keys()[cookie_type]
	return key_name
	
static func filter_cookies_type(cookie_list : Array, pCookie_type : TYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.cookie_type == pCookie_type )

static func filter_cookies_effect(cookie_list : Array, pCookie_effect :EFFECTYPE) -> Array:
	return cookie_list.filter(func(cookie):return cookie.effect_type == pCookie_effect )


static func list_to_dict(cookie_list : Array[Cookie]) -> Dictionary:
	print("Adding:", cookie_list)
	var dict = {}
	for value in TYPE.values():
		dict[value] = []
	for cookie in cookie_list:
		dict[cookie.cookie_type].append(cookie)
	print("Result:", dict)
	return dict
	
## Returns an empty dict of type Dictionary[COOKIETYPE, Array[Cookie]
static func type_dict() -> Dictionary:
	var dict = {}
	for value in TYPE.values():
		dict[value] = []
	return dict
	
#TODO: Might be good to have a function that returns the sprite of a given cookie type

static func type_description(cookie_type) -> String:
	var string = "defaultstring"
	match cookie_type:
		TYPE.Normal:
			string = "Party Deals 50% more damage when this cookie lands on the correct side"
		TYPE.Berserk:
			string ="Party Deals 100% more damage when this cookie lands on the correct side"
		TYPE.Golden:
			string = "10% more reward per mission if cookie lands correctly"
		TYPE.Replay:
			string = "50% chance to not loose it upon use. Party deals 25% more damage if guessed correctly"
		TYPE.Healing:
			string = "Heals the party by 35%, if guessed correctly"
		TYPE.Vampire:
			string = "Heals the party by a 35% of dealt damage, if guessed correctly"
		TYPE.Weighted:
			string = "When guessed correctly, during the next flip all the cookies placed on the same side have 25% bonus chance of landing correctly"
		TYPE.Crit:
			string = "When guessed correctly, party has 15% more chance of dealing a crit on next attack"
		TYPE.Fast:
			string = "If guessed correctly, party attacks 15% faster"
		TYPE.Head:
			string = "If guessed correctly, on next flip all cookies have 15% more chance of landing in heads"
		TYPE.Tail:
			string = "If guessed correctly, on next flip all cookies have 15% more chance of landing in tails"
	return string

static func type_price(cookie_type) -> int:
	var price = 0
	match cookie_type:
		TYPE.Normal:
			price = 1
		TYPE.Berserk:
			price = 3
		TYPE.Golden:
			price = 4
		TYPE.Replay:
			price = 4
		TYPE.Healing:
			price = 3
		TYPE.Vampire:
			price = 4
		TYPE.Weighted:
			price = 5
		TYPE.Crit:
			price = 4
		TYPE.Fast:
			price = 4
		TYPE.Head, TYPE.Tail:
			price = 4
	return price

static func type_sprite(cookie_type)  -> AtlasTexture:
	var head_atlas = AtlasTexture.new()
	# TODO: Ceci est assez degeu, Solution, creer les Cookies une fois, et les garder
	head_atlas.atlas = load("res://Assets/Sprites/CookieSheet.png")
	head_atlas.region = Rect2(0, cookie_type * 32, 32, 32)
	return head_atlas
	
