extends TextureRect

signal beginning_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $"."
@onready var title_2: TextureRect = $Title2
@onready var title: TextureRect = $Title

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


func spawn_tavern():
	var lTween: Tween = create_tween().set_parallel(true)
	lTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING).tween_property(title, "scale", Vector2.ONE, 1)
	lTween.tween_callback(sound1)
	lTween.chain().tween_property(title_2, "scale", Vector2.ONE, 1)
	lTween.tween_callback(sound2)
	lTween.tween_property(texture_rect, "scale", Vector2.ONE*4, 2).set_delay(2)
	lTween.tween_property(texture_rect, "position", texture_rect.position + Vector2(0,+200), 2).set_delay(2)
	lTween.tween_callback(sound3).set_delay(2)
	lTween.tween_callback(tween_finished).set_delay(3)
	lTween.tween_property(color_rect, "material:shader_parameter/progress", -1, 1).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_delay(2)
	
func sound1():
	SoundManager.instance.play_sound("Label1",true,false)
	
func sound2():
	SoundManager.instance.play_sound("Label2",true,false)

func sound3():
	SoundManager.instance.play_sound("Intro",true,false)

func tween_finished():
	color_rect.queue_free()
	texture_rect.queue_free()
	emit_signal("beginning_finished")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip"):
		emit_signal("beginning_finished")
		queue_free()
