extends Node

class_name LogicalCharacter

var sprite_frame: String
var health: float
var damage: float
var attack_speed: float
var crit: float
var side: String
var active_cookies : Dictionary = Cookie.type_dict()

enum TYPES  {Knight, Goblin, Skeleton, Cyclop, Devil, Wizard, Farmer, Necromancer, Pixie, Ranger, Dragon, Orc, Slime, Spider, Witch}

var DEBUG = true
func debug(to_print,confirm):
	if DEBUG and confirm:
		print(to_print)

#//////////function//////////
func _init(pHealth: int, pDamage: int, pAttack_speed: float, pCrit: float, pSprite_frame: String, pSide: String):
	health = pHealth
	damage = pDamage
	var random_offset : float = randf() * 0.5
	attack_speed = pAttack_speed + random_offset
	crit = pCrit
	sprite_frame = pSprite_frame
	side = pSide

func receive_cookie_POWER(received_cookies: Dictionary):
	# Allow stacking cookies, if flipped in succesion before attacks
	# We add them to the currently existing ones, if any needs to be triggered instantly
	# like the healing cookie does, we do it now, and if any are trigerred during active combat
	# we leave them in active_cookies
	# cookies : Dictionary [COOKIETYPE, Array[Cookie]]
	
	active_cookies = received_cookies
	#for key in received_cookies.keys():
	#	for cookie in received_cookies[key]:
	#		active_cookies[key].append(cookie)
			
	var healing_cookies = active_cookies.get(Cookie.TYPE.Healing)
	health += (health/3)*healing_cookies.size()
	debug("Healed!", healing_cookies.size() > 0)
	
	var fast_cookies = active_cookies.get(Cookie.TYPE.Fast)
	var timer_reduction = (attack_speed*0.15) * fast_cookies.size()
	attack_speed -= timer_reduction #this might possibly make it permanent between runs lol, It's a feature
			


func attack() -> Array:
	var damage_multiplier = 1
	
	# Damage Boosting cookies
	
	var normal_cookies = active_cookies.get(Cookie.TYPE.Normal)
	damage_multiplier += 0.5 * normal_cookies.size()
	debug("Normal!", normal_cookies.size() > 0)
	
	# Berserk Cookie
	var berserk_cookies = active_cookies.get(Cookie.TYPE.Berserk)
	damage_multiplier += 2 * berserk_cookies.size()
	debug("Berserk!", berserk_cookies.size() > 0)
	
	# Critical Boosting Cookies
	var critical_bonus := 0.0
	var critical_cookies = active_cookies.get(Cookie.TYPE.Crit)
	critical_bonus += 0.2 * critical_cookies.size()
	debug("Critical!", critical_cookies.size() > 0)
	
	# Array Float Bool
	
	var crit_info : Array  = calculate_crit(damage*damage_multiplier, critical_bonus)
	var total_damage : float = crit_info[0]
	print("x: ", damage_multiplier," d: ", total_damage, damage_multiplier," t: ", total_damage*damage_multiplier)
	# Damage using cookies
	# Vampire cookie
	var vampire_cookies = active_cookies.get(Cookie.TYPE.Vampire)
	health += (total_damage/3) * vampire_cookies.size()
	debug("Vampire!", vampire_cookies.size() > 0)
	
	active_cookies = Cookie.type_dict() # Resetting to empty
	return [total_damage, crit_info[1]]
	
	

func calculate_crit(pDamage: float, pBonus_chance: float) -> Array:
	randomize() # TODO Faut bouger ce truc qui pue ailleurs
	pBonus_chance = clamp(pBonus_chance, 0.0, 1.0)
	var lCrit_chance: float = crit 
	var total_chance: float = clamp(lCrit_chance + pBonus_chance, 0.0, 1)
	
	var crit_triggered : bool = false
	if randf() <= total_chance:
		pDamage *= 1.5 
		crit_triggered = true

	return [pDamage, crit_triggered]
