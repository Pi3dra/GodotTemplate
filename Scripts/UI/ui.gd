extends CanvasLayer

class_name UI

signal beginning_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect
@onready var title_2: TextureRect = $TextureRect/Title2
@onready var title: TextureRect = $TextureRect/Title

const GAME_SCENE = preload("uid://xy0wonkog4ns")

static var instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	if Globals.current_tutorial == null: 
		call_deferred("tween_finished")
		return
	
	var lTween: Tween = create_tween().set_parallel(true)
	lTween.tween_property(color_rect, "material:shader_parameter/progress", 3.5, 2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	lTween.tween_callback(spawn_tavern).set_delay(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_tavern():
	var lTween: Tween = create_tween().set_parallel(true)
	lTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING).tween_property(title, "scale", Vector2.ONE, 1)
	lTween.chain().tween_property(title_2, "scale", Vector2.ONE, 1)
	lTween.tween_property(texture_rect, "scale", Vector2.ONE*4, 2).set_delay(2)
	lTween.tween_property(texture_rect, "position", texture_rect.position + Vector2(0,+200), 2).set_delay(2)
	lTween.tween_callback(tween_finished).set_delay(3)
	lTween.tween_property(color_rect, "material:shader_parameter/progress", -1, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(2)
	
func tween_finished():
	color_rect.queue_free()
	texture_rect.queue_free()
	var game = GAME_SCENE.instantiate()
	Main.instance.add_child(game)
	emit_signal("beginning_finished")
