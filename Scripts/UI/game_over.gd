extends Control

@onready var retry: RichTextLabel = $ButRetry/RETRY
@onready var game_over: RichTextLabel = $"GAME OVER"

var main_scene: PackedScene = load("uid://dsrw2guvcxik7")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.instance.play_sound("Level1", false)
	SoundManager.instance.play_sound("Level2", false)
	SoundManager.instance.play_sound("Level3", false)
	SoundManager.instance.play_sound("Lose", true)
	var lTween = create_tween().set_parallel(true)
	lTween.tween_property(retry, "modulate:a", 1, 3)
	lTween.tween_property(game_over, "modulate:a", 1, 3)
	

func _on_but_retry_pressed() -> void:
	Main.instance.queue_free()
	
	var lMain: Main = main_scene.instantiate()
	get_tree().root.add_child(lMain)
