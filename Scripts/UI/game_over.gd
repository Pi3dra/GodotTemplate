extends Control

@onready var retry: RichTextLabel = $ButRetry/RETRY
@onready var game_over: RichTextLabel = $"GAME OVER"

var main_scene: PackedScene = load("uid://dsrw2guvcxik7")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.instance.play_sound("Lose", true)
	#move_child(parent_game_over, get_children().size())
	#but_retry.position = camera_2d.position + Vector2(0,100) - but_retry.pivot_offset
	#game_over.position = camera_2d.position - Vector2(0,100) - game_over.pivot_offset
	var lTween = create_tween().set_parallel(true)
	lTween.tween_property(retry, "modulate:a", 1, 3)
	lTween.tween_property(game_over, "modulate:a", 1, 3)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#func lose() -> void:
	#move_child(parent_game_over, get_children().size())
	#color_rect_2.position = camera_2d.global_position - Vector2(color_rect_2.pivot_offset.x, color_rect_2.pivot_offset.y)
	
	



func _on_but_retry_pressed() -> void:
	Main.instance.queue_free()
	var lMain: Main = main_scene.instantiate()
	get_tree().root.add_child(lMain)
