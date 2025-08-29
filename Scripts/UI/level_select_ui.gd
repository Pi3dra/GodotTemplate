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
		print(levels)
		level.connect("wave_information", send_level_start)
		
func send_level_start(wave_info):
	emit_signal("start_level", wave_info)
	hide()

# Array[Array[LogicalCharacter.TYPE]] = [[Goblin;,Skelet],[],[]]
signal start_level(wave_info)


func _on_exit_pressed() -> void:
	hide()
	#queue_free()
