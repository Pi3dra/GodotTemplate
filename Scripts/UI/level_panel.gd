extends Control

class_name LevelPanel

@onready var head_display = $PanelContainer/EnemyDisplay
@onready var difficulty_label: Label = $Difficulty

@onready var reward_title: Label = $RewardTitle
@onready var font = load("uid://b0ndjepym4tga")

var sprites = preload("uid://damlxqw3n3qsv")

var data: LevelData

@onready var reward_container = $VBoxContainer/TextContainer

var spriteorder = {
	LogicalCharacter.TYPE.SKELETON: 1,
	LogicalCharacter.TYPE.SLIME: 4,
	LogicalCharacter.TYPE.SPIDER: 3,
	LogicalCharacter.TYPE.ORC: 5,
	LogicalCharacter.TYPE.WITCH: 2,
	LogicalCharacter.TYPE.GOBLIN: 0,
	LogicalCharacter.TYPE.CYCLOP: 8,
	LogicalCharacter.TYPE.DEVIL: 7,
	LogicalCharacter.TYPE.DRAGON: 6,
}


func add_reward(type, number):
	var container = HBoxContainer.new()
	var label = Label.new()
	var image = TextureRect.new()
	label.add_theme_font_override("font", font)
	label.text = "X" + str(number)
	image.texture = Globals.get_cookie_data(type).head_texture

	container.add_child(image)
	container.add_child(label)
	reward_container.add_child(container)


func generate_level(difficulty: LevelData.Difficulty):
	data = LevelData.new(difficulty)
	reward_title.add_theme_font_override("font", font)

	difficulty_label.text = LevelData.Difficulty.keys()[difficulty] + "\n"

	for type in data.rewards.keys():
		add_reward(type, data.rewards.get(type))

	var enemy_count = count_enemies()
	for enemy in enemy_count.keys():
		var icon = TextureRect.new()
		var texture = AtlasTexture.new()
		texture.atlas = sprites
		texture.region = Rect2(Vector2(spriteorder[enemy] * 32, 0), Vector2(32, 32))
		icon.texture = texture
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var label = Label.new()
		label.text = "X%d" % enemy_count[enemy]
		# Create a StyleBoxTexture and assign the image
		var style = StyleBoxTexture.new()

		# Apply StyleBox to normal, pressed, and hover states
		label.add_theme_stylebox_override("normal", style)
		label.add_theme_stylebox_override("pressed", style)
		label.add_theme_stylebox_override("hover", style)
		head_display.add_child(icon)
		head_display.add_child(label)


func count_enemies():
	var enemy_count: Dictionary[LogicalCharacter.TYPE, int]
	for wave in data.wave_data:
		for enemy in wave:
			if enemy_count.has(enemy):
				enemy_count.set(enemy, enemy_count.get(enemy) + 1)
			else:
				enemy_count.set(enemy, 1)
	return enemy_count


signal wave_information(data)


func _on_button_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	emit_signal("wave_information", data)


func _on_button_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_button_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
