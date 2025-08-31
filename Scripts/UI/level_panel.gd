extends Control

class_name level_panel

@onready var head_display = $VBoxContainer/PanelContainer/EnemyDisplay
@onready var difficulty_label: Label = $Difficulty

@onready var reward_title: Label = $VBoxContainer/RewardTitle
@onready var reward_1: Label = $VBoxContainer/TextContainer/HBoxContainer/Reward1
@onready var reward_2: Label = $VBoxContainer/TextContainer/HBoxContainer2/Reward2
@onready var font = load("uid://b0ndjepym4tga")

var total_enemies = 3*5

enum Difficulty { Easy, Medium, Hard}

# This is bubbled up to the arena
var waves

var level_difficulty
var reward1
var reward2
var wave_info

var spriteorder = {LogicalCharacter.TYPES.Skeleton : 1, LogicalCharacter.TYPES.Slime : 4, LogicalCharacter.TYPES.Spider : 3,
	LogicalCharacter.TYPES.Orc : 5, LogicalCharacter.TYPES.Witch : 2, LogicalCharacter.TYPES.Goblin:0,
	LogicalCharacter.TYPES.Cyclop : 8, LogicalCharacter.TYPES.Devil : 7, LogicalCharacter.TYPES.Dragon : 6
}
var easy_enemies = [LogicalCharacter.TYPES.Skeleton, LogicalCharacter.TYPES.Slime, LogicalCharacter.TYPES.Spider]
var medium_enemies = [LogicalCharacter.TYPES.Orc, LogicalCharacter.TYPES.Witch, LogicalCharacter.TYPES.Goblin]
var hard_enemies = [LogicalCharacter.TYPES.Cyclop, LogicalCharacter.TYPES.Devil, LogicalCharacter.TYPES.Dragon]
var enemy_palette = { Difficulty.Easy : easy_enemies, Difficulty.Medium : medium_enemies, Difficulty.Hard : hard_enemies}

var sprites = preload("uid://damlxqw3n3qsv")

# This would be way cleaner with a class
# consisting of a:
# - setter
# - constructor
# - getter
# - drawer

#func _ready():
#   For some reason when ready is called the panel layout gets fd up
#	set_panel(Difficulty.Hard, [[LogicalCharacter.TYPES.Goblin]], [5,5])

func generate_level(difficulty : Difficulty):
	reward_title.add_theme_font_override("font",font)
	reward_1.add_theme_font_override("font",font)
	reward_2.add_theme_font_override("font",font)
	
	difficulty_label.text = Difficulty.keys()[difficulty] + "\n"
	var used_enemies : int
	var cookies : int
	var special_cookies : int
	
	match difficulty:
		Difficulty.Hard:
			used_enemies = 14
			cookies = 60 + randi()%6
			special_cookies = 5 + randi()%2
		Difficulty.Medium:
			used_enemies = randi() % 4 + 8
			cookies = 30 + randi()%3
			special_cookies = 3 + randi()%2
		Difficulty.Easy:
			used_enemies = randi() % 2 + 3
			cookies = 20 + randi()%3
			special_cookies = 0
			
	reward_1.text = str(cookies) +" x Cookies"
	reward_2.text = str(special_cookies) +" x Special Cookies"
	var waves : Array = distribute_enemies(used_enemies)
	var enemy_info = pick_enemies(waves, difficulty) #Array[Array[LogicalCharacter.TYPES]]
	var enemy_waves = enemy_info.get("Waves")
	var enemy_count = enemy_info.get("Counter")
	
	
	for enemy in enemy_count.keys():
		var icon = TextureRect.new()
		var texture = AtlasTexture.new()
		texture.atlas = sprites
		texture.region = Rect2(Vector2(spriteorder[enemy]*32, 0), Vector2(32,32))
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
		
	# This gets sent through signal
	wave_info = enemy_waves 
	level_difficulty = difficulty
	reward1 = cookies
	reward2 = special_cookies
	
func distribute_enemies(number_of_enemies):
	randomize()
	var waves : Array = [0,0,0]
	var counter = number_of_enemies
	
	if number_of_enemies == 14:
		return [5,5,4]
	
	while counter > 0:
		var selected_index = randi() % 3
		if waves[selected_index] < 5:
			waves[selected_index] += 1
			counter -= 1
	
	if 0 in waves:
		return distribute_enemies(number_of_enemies)
	else:
		return waves

func pick_enemies(waves : Array, difficulty : Difficulty):
	var enemy_waves : Array = []
	var enemy_counter : Dictionary[int, int]
	for number_of_enemies in waves:
		var wave = []
		for i in range(number_of_enemies):
			var enemy = enemy_palette[difficulty].pick_random()
			if !enemy_counter.has(enemy):
				enemy_counter.set(enemy, 0)
			enemy_counter.set(enemy,enemy_counter.get(enemy) + 1)  
			wave.append(enemy)
		enemy_waves.append(wave)
	return {"Waves" : enemy_waves, "Counter" : enemy_counter}
	

signal wave_information(wave)
func _on_button_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	emit_signal("wave_information", wave_info, reward1, reward2)


func _on_button_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_button_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
