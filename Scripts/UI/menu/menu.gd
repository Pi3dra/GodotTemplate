extends Control

@export var play: Button
@export var options: Button
@export var quit: Button

const GAME_SCENE = preload("uid://xy0wonkog4ns") # We use preaload because this scene can be heavy to load
var OptionsScene = load("uid://s0d8plmcaf7v") # We use load because this scene is light and doesn't need to clutter the RAM


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass


func _on_play_pressed() -> void:
	var game = GAME_SCENE.instantiate()
	Main.instance.add_child(game)
	queue_free()

func _on_options_pressed() -> void:
	var option = OptionsScene.instantiate()
	get_parent().add_child(option)
	hide()


func _on_quit_pressed() -> void:
	get_tree().quit()
