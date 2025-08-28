class_name GameScene

extends Node2D

static var instance

## Register of all the characters existing
static var pokedex = {
							#6
	# Good Ones
	LogicalCharacter.TYPES.Knight : {"Health": 20, "Damage": 3.0, "Speed": 2.1, "Crit": 0.15, "Sprite": "uid://b2ygb7ty6nyn7", "Side": "Good"},
	LogicalCharacter.TYPES.Farmer : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://bsek4eo8s6x7f", "Side": "Good"},
	LogicalCharacter.TYPES.Necromancer : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://b28w73d4lebir", "Side": "Good"},
	LogicalCharacter.TYPES.Pixie : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://x0ln8ilbb2yi", "Side": "Good"},
	LogicalCharacter.TYPES.Ranger : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://cd1mc8i0dxna8", "Side": "Good"},
	LogicalCharacter.TYPES.Wizard : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://ceggmtt6ni5yw", "Side": "Good"},
	# Bad
	# Easy 
	LogicalCharacter.TYPES.Slime : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://bo5odqepabyb0", "Side": "Bad"},
	LogicalCharacter.TYPES.Spider : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://cyh1tdlwcvgcq", "Side": "Bad"},
	LogicalCharacter.TYPES.Skeleton : {"Health": 6, "Damage": 3.0, "Speed": 3.0, "Crit": 0.1, "Sprite": "uid://8ad7ga6kijxa", "Side": "Bad"},
	
	# Medium
	LogicalCharacter.TYPES.Goblin : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://dvre1pai1vrju", "Side": "Bad"},
	LogicalCharacter.TYPES.Witch : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://nxn6dsoumjue", "Side": "Bad"},
	LogicalCharacter.TYPES.Orc : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://csp13l6otqmai", "Side": "Bad"},
	
	# Hard
	LogicalCharacter.TYPES.Devil : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://dfv7ax1wpkyw7", "Side": "Bad"},
	LogicalCharacter.TYPES.Dragon : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://cab6yfatfkggn", "Side": "Bad"},
	LogicalCharacter.TYPES.Cyclop : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://dis7wt2jwl2yo", "Side": "Bad"},
	
	
	
	
}

#//////////function//////////
func _ready() -> void:
	instance = self
