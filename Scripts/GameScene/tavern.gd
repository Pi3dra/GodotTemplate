extends Node2D

@export var arena: Button
var arena_scene: PackedScene = load("uid://ccgdngh77m0hc")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var lArena = arena_scene.instantiate()
	get_parent().add_child(lArena)
	hide()
