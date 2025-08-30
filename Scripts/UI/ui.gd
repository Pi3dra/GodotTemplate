extends CanvasLayer

class_name UI

signal beginning_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var brackeys: TextureRect = $Brackeys
@onready var title: TextureRect = $Title
@onready var title_2: TextureRect = $Title2

const GAME_SCENE = preload("uid://xy0wonkog4ns")

static var instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	var lTween: Tween = create_tween().set_parallel(true)
	lTween.tween_property(color_rect, "material:shader_parameter/progress", 2.8, 2)
	lTween.tween_callback(spawn_tavern).set_delay(2.5)
	lTween.tween_callback(tween_finished).set_delay(6)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_tavern():
	var lTween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	lTween.tween_property(brackeys,"position", brackeys.position + Vector2(0, 700), 1.0)

func tween_finished():
	brackeys.queue_free()
	color_rect.queue_free()
	var game = GAME_SCENE.instantiate()
	Main.instance.add_child(game)
	emit_signal("beginning_finished")
