extends AnimatedSprite2D

var character : LogicalCharacter.TYPE
var price : int

var ally_infos_tscn: PackedScene = load("uid://dms6ws1wlx0ww")
var ally_infos: Control

@onready var label = $HBoxContainer/Label
@onready var texture_rect = $HBoxContainer/TextureRect

func _ready() -> void:
	init_info_data()
	
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER  # keep centered
	texture_rect.custom_minimum_size.y = label.size.y  # force minimum height
	play()

### Ceci aussi est bien degueu, a mettre dans pokedex ou characterclass.gd
func char_to_price(character_type: LogicalCharacter.TYPE):
	match character_type:
		LogicalCharacter.TYPE.Wizard:
			return 12 + randi()%4
		LogicalCharacter.TYPE.Knight:
			return 10 + randi()%4
		LogicalCharacter.TYPE.Farmer:
			return 3 + randi()%4
		LogicalCharacter.TYPE.Pixie:
			return 2 + randi()%4
		LogicalCharacter.TYPE.Necromancer:
			return 10 + randi()%4
		_:
			return 2

	

func init_char(pCharacter: LogicalCharacter.TYPE):
	sprite_frames = Globals.get_character_data(pCharacter).animations
	play()
	var pPrice : int = char_to_price(pCharacter)
	label.text = str(pPrice) + "X"
	character = pCharacter
	price = pPrice
	ally_infos.health_bar.value = Globals.get_character_data(pCharacter).health
	ally_infos.damage_bar.value = Globals.get_character_data(pCharacter).damage
	ally_infos.speed_bar.value = Globals.get_character_data(pCharacter).speed
	ally_infos.crit_bar.value = Globals.get_character_data(pCharacter).crit
	
	

signal buy_character(character, price )
func _on_texture_button_button_down() -> void:
	emit_signal("buy_character", character, price)
	

func init_info_data():
	ally_infos = ally_infos_tscn.instantiate()
	add_child(ally_infos)
	ally_infos.hide()
	
	

func _on_area_2d_mouse_entered() -> void:
	ally_infos.show()
	$HBoxContainer.show()
	$TextureButton.show()
	scale = Vector2(1.5,1.5)
	Cursor.instance.texture = Cursor.point


func _on_area_2d_mouse_exited() -> void:
	ally_infos.hide()
	$TextureButton.hide()
	$HBoxContainer.hide()
	scale = Vector2(1,1)
	Cursor.instance.texture = Cursor.basic
