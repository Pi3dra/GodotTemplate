extends Node

class_name LogicalCharacter


var sprite_frame: String
var health: int
var damage: int
var attack_speed: float
var crit: float
var side: String

#//////////function//////////
func _init(pHealth: int, pDamage: int, pAttack_speed: float, pCrit: float, pSprite_frame: String, pSide: String):
	health = pHealth
	damage = pDamage
	attack_speed = pAttack_speed
	crit = pCrit
	sprite_frame = pSprite_frame
	side = pSide


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass
