class_name GameScene
extends Node2D

static var instance


#//////////function//////////
func _ready() -> void:
	LevelData.new(LevelData.Difficulty.MEDIUM)
	instance = self
