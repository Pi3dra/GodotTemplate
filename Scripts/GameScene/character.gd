extends  Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var character : LogicalCharacter 


#//////////function//////////
func _ready() -> void:
	animated_sprite = get_child(0) as AnimatedSprite2D # Because it's AnimSprite2D is the only child
	animated_sprite.sprite_frames = load(character.sprite_frame) as SpriteFrames # Load accordingly to the logical character
	animated_sprite.play("idle")


func _process(delta: float) -> void:
	pass
