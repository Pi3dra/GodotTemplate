class_name GameScene

extends Node2D

static var instance

## Register of all the characters existing
static var pokedex = {
	#TODO Move this to resources!
							
	# Good Ones
	LogicalCharacter.TYPE.Knight : {"Health": 210, "Damage": 20.0, "Speed": 4.1, "Crit": 0.2, "Sprite": "uid://b2ygb7ty6nyn7", "Side": "Good", "Shooter": false},
	LogicalCharacter.TYPE.Farmer : {"Health": 190, "Damage": 10.0, "Speed": 4.3, "Crit": 0.1, "Sprite": "uid://bsek4eo8s6x7f", "Side": "Good", "Shooter": false},
	LogicalCharacter.TYPE.Necromancer : {"Health": 170, "Damage": 25.0, "Speed": 3, "Crit": 0.1, "Sprite": "uid://b28w73d4lebir", "Side": "Good", "Shooter": true},
	LogicalCharacter.TYPE.Pixie : {"Health": 100, "Damage": 5.0, "Speed": 3.9, "Crit": 0.1, "Sprite": "uid://x0ln8ilbb2yi", "Side": "Good", "Shooter": true},
	LogicalCharacter.TYPE.Ranger : {"Health": 200, "Damage": 20, "Speed": 3.9, "Crit": 0.2, "Sprite": "uid://cd1mc8i0dxna8", "Side": "Good", "Shooter": true},
	LogicalCharacter.TYPE.Wizard : {"Health": 180, "Damage": 25.0, "Speed": 3.9, "Crit": 0.1, "Sprite": "uid://ceggmtt6ni5yw", "Side": "Good", "Shooter": true},
	# Bad
	# Easy 
	LogicalCharacter.TYPE.Slime : {"Health": 100, "Damage": 10.0, "Speed": 4.5, "Crit": 0.05, "Sprite": "uid://bo5odqepabyb0", "Side": "Bad", "Shooter": false},
	LogicalCharacter.TYPE.Spider : {"Health": 100, "Damage": 10.0, "Speed": 4.9, "Crit": 0.05, "Sprite": "uid://cyh1tdlwcvgcq", "Side": "Bad", "Shooter": false},
	LogicalCharacter.TYPE.Skeleton : {"Health": 100, "Damage": 10.0, "Speed": 5.0, "Crit": 0.05, "Sprite": "uid://8ad7ga6kijxa", "Side": "Bad", "Shooter": false},
	
	# Medium
	LogicalCharacter.TYPE.Goblin : {"Health": 200, "Damage": 15.0, "Speed": 3.9, "Crit": 0.05, "Sprite": "uid://dvre1pai1vrju", "Side": "Bad", "Shooter": false},
	LogicalCharacter.TYPE.Witch : {"Health": 200, "Damage": 15.0, "Speed": 4.8, "Crit": 0.05, "Sprite": "uid://nxn6dsoumjue", "Side": "Bad", "Shooter": true},
	LogicalCharacter.TYPE.Orc : {"Health": 200, "Damage": 15.0, "Speed": 4.2, "Crit": 0.05, "Sprite": "uid://csp13l6otqmai", "Side": "Bad", "Shooter": false},
	
	# Hard
	LogicalCharacter.TYPE.Devil : {"Health": 300 , "Damage": 20.0, "Speed": 5, "Crit": 0.1, "Sprite": "uid://dfv7ax1wpkyw7", "Side": "Bad", "Shooter": false},
	LogicalCharacter.TYPE.Dragon : {"Health": 300, "Damage": 20.0, "Speed": 5.3, "Crit": 0.1, "Sprite": "uid://cab6yfatfkggn", "Side": "Bad", "Shooter": true},
	LogicalCharacter.TYPE.Cyclop : {"Health": 300, "Damage": 20.0, "Speed": 5.1, "Crit": 0.1, "Sprite": "uid://dis7wt2jwl2yo", "Side": "Bad", "Shooter": true},
	
	LogicalCharacter.TYPE.Unkillable_Slime : {"Health": 10000, "Damage": 0.0, "Speed": 2.5, "Crit": 0.1, "Sprite": "uid://bo5odqepabyb0", "Side": "Bad", "Shooter": false}
	
	
}

#//////////function//////////
func _ready() -> void:
	instance = self
