extends Node

class_name LogicalCharacter

enum TYPE {
	KNIGHT,
	GOBLIN,
	SKELETON,
	CYCLOP,
	DEVIL,
	WIZARD,
	FARMER,
	NECROMANCER,
	PIXIE,
	RANGER,
	DRAGON,
	ORC,
	SLIME,
	SPIDER,
	WITCH,
	UNKILLABLE_SLIME,
}
enum SIDE { GOOD, BAD }

var sprite_frame: SpriteFrames
var projectile: CompressedTexture2D
var total_health: float
var health: float
var damage: float
var attack_speed: float
var crit: float
var side: SIDE
var type: TYPE
var shooter: bool
var char_instance: Node
var active_cookies: Dictionary = { }
var debug_enabled = false


func debug(to_print, confirm):
	if debug_enabled and confirm:
		print(to_print)


#//////////function//////////
func _init(character_type: LogicalCharacter.TYPE):
	type = character_type
	var char_data: CharacterData = Globals.get_character_data(character_type)
	#Combat
	health = char_data.health
	total_health = char_data.health
	damage = char_data.damage
	var random_offset: float = randf() * 0.5
	attack_speed = char_data.speed + random_offset
	crit = char_data.crit
	side = char_data.side
	shooter = char_data.shooter
	#Animation
	sprite_frame = char_data.animations
	projectile = char_data.projectile


func receive_cookie_power(received_cookies: Dictionary):
	# Allow stacking cookies, if flipped in succesion before attacks
	# We add them to the currently existing ones, if any needs to be triggered instantly
	# like the healing cookie does, we do it now, and if any are trigerred during active combat
	# we leave them in active_cookies
	# cookies : Dictionary [COOKIETYPE, Array[Cookie]]

	active_cookies = received_cookies

	var fast_cookies = active_cookies.get(Cookie.TYPE.FAST, 0)
	var timer_reduction = 0
	for i in range(fast_cookies):
		timer_reduction = attack_speed * 0.15
		attack_speed = attack_speed - timer_reduction
	#this might possibly make it permanent between runs lol, It's a feature
	attack_speed -= timer_reduction
	debug("Speed! " + str(attack_speed), fast_cookies > 0)


func attack() -> Array:
	var damage_multiplier = 1

	# Damage Boosting cookies
	var normal_cookies = active_cookies.get(Cookie.TYPE.NORMAL, 0)
	damage_multiplier += 2 * normal_cookies
	debug("Normal!", normal_cookies > 0)

	# Critical Boosting Cookies
	var critical_bonus := 0.0
	var critical_cookies = active_cookies.get(Cookie.TYPE.CRIT, 0)
	critical_bonus = clamp(critical_bonus + .2 * critical_cookies, 0.0, 1.0)
	debug("Critical!", critical_cookies > 0)

	# Array Float Bool
	var crit_info: Array = calculate_crit(damage * damage_multiplier, critical_bonus)
	var total_damage: float = crit_info[0]

	# Vampire cookie
	var vampire_cookies = active_cookies.get(Cookie.TYPE.VAMPIRE, 0)
	var healing = (total_damage / 3) * vampire_cookies
	health = clamp(health + healing, 0, total_health)
	if vampire_cookies > 0:
		char_instance.animate_health_bar()
		char_instance.show_damage(crit_info[1], healing, true)
	debug("Vampire!", vampire_cookies > 0)

	return [total_damage, crit_info[1]]


func calculate_crit(attack_damage: float, bonus_chance: float) -> Array:
	randomize()
	bonus_chance = clamp(bonus_chance, 0.0, 1.0)
	var crit_chance: float = crit
	var total_chance: float = clamp(crit_chance + bonus_chance, 0.0, 1)

	var crit_triggered: bool = false
	if randf() <= total_chance:
		attack_damage *= 2
		crit_triggered = true

	return [attack_damage, crit_triggered]
