class_name GameScene

extends Node2D

static var instance

## Register of all the characters existing
static var pokedex = {
	"Skeleton": {"Health": 6, "Damage": 3, "Speed": 3.0, "Crit": 0.1, "Sprite": "uid://8ad7ga6kijxa"},
	"Knight": {"Health": 20, "Damage": 4, "Speed": 2.2, "Crit": 0.2, "Sprite": "uid://b2ygb7ty6nyn7"},
	"Goblin": {"Health": 10, "Damage": 3, "Speed": 1.9, "Crit": 0.1, "Sprite": "uid://dvre1pai1vrju"},
	
}

#//////////function//////////
func _ready() -> void:
	instance = self


func _process(delta: float) -> void:
	pass
