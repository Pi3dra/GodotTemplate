extends Control

class_name level_select_ui

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var lvl1 = $HBoxContainer/Level1
@onready var lvl2 = $HBoxContainer/Level2
@onready var lvl3 = $HBoxContainer/Level3

static var instance

func _ready():
	instance = self
	var levels = [lvl1, lvl2, lvl3]
	lvl1.generate_level(level_panel.Difficulty.Easy)
	lvl2.generate_level(level_panel.Difficulty.Medium)
	lvl3.generate_level(level_panel.Difficulty.Hard)
	for level in levels:
		level.connect("wave_information", send_level_start)
		
func send_level_start(wave_info, reward1, reward2):
	emit_signal("start_level", wave_info, reward1, reward2)
	hide()

func regen():
	instance = self
	var levels = [lvl1, lvl2, lvl3]
	lvl1.generate_level(level_panel.Difficulty.Easy)
	lvl2.generate_level(level_panel.Difficulty.Medium)
	lvl3.generate_level(level_panel.Difficulty.Hard)
	
# Array[Array[LogicalCharacter.TYPE]] = [[Goblin;,Skelet],[],[]]
signal start_level(wave_info)


func _on_exit_pressed() -> void:
	SoundManager.instance.play_sound("Click2", true, false)
	hide()
	#queue_free()


func _on_exit_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_exit_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
