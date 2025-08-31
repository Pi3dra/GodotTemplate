extends AnimatedSprite2D

var character : LogicalCharacter.TYPES
var price : int

@onready var label = $HBoxContainer/Label
@onready var texture_rect = $HBoxContainer/TextureRect

func _ready() -> void:
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # keep centered
	texture_rect.custom_minimum_size.y = label.size.y  # force minimum height
	play()

### Ceci aussi est bien degueu, a mettre dans pokedex ou characterclass.gd
func char_to_price(character_type: LogicalCharacter.TYPES):
	match character_type:
		LogicalCharacter.TYPES.Wizard:
			return 12 + randi()%4
		LogicalCharacter.TYPES.Knight:
			return 10 + randi()%4
		LogicalCharacter.TYPES.Farmer:
			return 3 + randi()%4
		LogicalCharacter.TYPES.Pixie:
			return 2 + randi()%4
		LogicalCharacter.TYPES.Necromancer:
			return 10 + randi()%4
		_:
			return 2

	

func init_char(pCharacter: LogicalCharacter.TYPES):
	sprite_frames = LogicalCharacter.char_to_sprite(pCharacter)
	play()
	var pPrice : int = char_to_price(pCharacter)
	label.text = str(pPrice) + "X"
	character = pCharacter
	price = pPrice
	

signal buy_character(character, price )
func _on_texture_button_button_down() -> void:
	emit_signal("buy_character", character, price)

func _on_area_2d_mouse_entered() -> void:
	$HBoxContainer.show()
	$TextureButton.show()
	scale = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.point


func _on_area_2d_mouse_exited() -> void:
	$TextureButton.hide()
	$HBoxContainer.hide()
	scale = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic
