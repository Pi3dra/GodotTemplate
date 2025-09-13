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
	return Globals.get_character_data(character_type).price + randi()%4
	
func init_char(pCharacter: LogicalCharacter.TYPE):
	var char_data = Globals.get_character_data(pCharacter)
	sprite_frames = char_data.animations
	play()
	var pPrice : int = char_to_price(pCharacter)
	label.text = str(pPrice) + "X"
	character = pCharacter
	price = pPrice

	ally_infos.health_bar.value = char_data.health
	ally_infos.damage_bar.value = char_data.damage
	ally_infos.speed_bar.value = char_data.speed
	ally_infos.crit_bar.value = char_data.crit
	
signal buy_character()
func _on_texture_button_button_down() -> void:
	#parent handles buying a char
	emit_signal("buy_character")
	
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
