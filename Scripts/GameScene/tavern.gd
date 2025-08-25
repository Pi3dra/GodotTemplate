extends Node2D

@onready var arena: Node2D = $"../Arena"

var chosen_enemies: Array[String] = []


#//////////function//////////
func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	pass


# Go to combat
func _on_button_pressed() -> void:
	arena.show()
	hide()
