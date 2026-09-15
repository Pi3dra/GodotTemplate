extends Node

class_name Main
static var manager: WorldManager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root_node = $"."
	manager = WorldManager.new(root_node)

	SoundManager.play("Crash-Landing")
