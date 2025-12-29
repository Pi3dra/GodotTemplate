extends Control

@onready var retry: RichTextLabel = $ButRetry/RETRY
@onready var game_over: RichTextLabel = $"GAME OVER"

var main_scene: PackedScene = load("uid://dsrw2guvcxik7")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.instance.play_sound("SONG1", false)
	SoundManager.instance.play_sound("SONG2", false)
	SoundManager.instance.play_sound("SONG3", false)
	SoundManager.instance.play_sound("Lose", true)
	var tween = create_tween().set_parallel(true)
	tween.tween_property(retry, "modulate:a", 1, 3)
	tween.tween_property(game_over, "modulate:a", 1, 3)


func _on_but_retry_pressed() -> void:
	Main.instance.queue_free()

	var main: Main = main_scene.instantiate()
	get_tree().root.add_child(main)
