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
			return 2
		LogicalCharacter.TYPES.Knight:
			return 2
		LogicalCharacter.TYPES.Farmer:
			return 2
		LogicalCharacter.TYPES.Pixie:
			return 2
		LogicalCharacter.TYPES.Necromancer:
			return 2
		_:
			return 2

	
## Ceci est degueu, on devrait plutot ecrire directement dans pokedex ou character class
func char_to_sprite(char: LogicalCharacter.TYPES):
	match char:
			LogicalCharacter.TYPES.Knight:
				return load("uid://bya4yxuvdd8au")
			LogicalCharacter.TYPES.Wizard:
				return load("uid://web178x58oer")
			LogicalCharacter.TYPES.Farmer:
				return load("uid://d4bsbcou2jxx0")
			LogicalCharacter.TYPES.Necromancer:
				return load("uid://devpvt8vd06qp")
			LogicalCharacter.TYPES.Ranger:
				return load("uid://3x72wu7mgqcc")
				

func init_char(pCharacter: LogicalCharacter.TYPES):
	sprite_frames = char_to_sprite(pCharacter)
	play()
	var pPrice : int = char_to_price(pCharacter)
	label.text = str(pPrice) + "X"
	character = pCharacter
	price = pPrice
	

signal buy_character(character, price )
func _on_texture_button_button_down() -> void:
	emit_signal("buy_character", character, price)
	print("bought")


func _on_area_2d_mouse_entered() -> void:
	print("test")
	$HBoxContainer.show()
	$TextureButton.show()
	scale = Vector2(1.5,1.5)


func _on_area_2d_mouse_exited() -> void:
	$TextureButton.hide()
	$HBoxContainer.hide()
	scale = Vector2(1,1)
