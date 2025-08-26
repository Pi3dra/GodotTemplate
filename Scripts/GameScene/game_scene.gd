class_name GameScene

extends Node2D

static var instance

## Register of all the characters existing
static var pokedex = {
							#6
	LogicalCharacter.TYPES.Skeleton : {"Health": 6, "Damage": 3.0, "Speed": 3.0, "Crit": 0.1, "Sprite": "uid://8ad7ga6kijxa", "Side": "Bad"},
	LogicalCharacter.TYPES.Knight : {"Health": 20, "Damage": 3.0, "Speed": 2.1, "Crit": 0.15, "Sprite": "uid://b2ygb7ty6nyn7", "Side": "Good"},
	LogicalCharacter.TYPES.Goblin : {"Health": 100, "Damage": 2.0, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://dvre1pai1vrju", "Side": "Bad"},
}

#//////////function//////////
func _ready() -> void:
	instance = self
