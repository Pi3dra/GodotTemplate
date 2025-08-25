class_name Cookie
var id
var description
var cookie_type : Globals.COOKIETYPE

var tail_texture : AtlasTexture
var head_texture : AtlasTexture
var shadow_texture = preload("res://Assets/Sprites/Cookies/cookie_shadow.png")
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
	
	#WHY THE HELL IS THIS INVERTED?
	tail_texture = tail_atlas
	head_texture = head_atlas
	
#TODO: Might be good to have a function that returns the sprite of a given cookie type
