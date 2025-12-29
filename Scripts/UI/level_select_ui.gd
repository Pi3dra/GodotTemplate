extends Control

@onready var h_box_container: HBoxContainer = $HBoxContainer
@onready var lvl1 = $HBoxContainer/Level1
@onready var lvl2 = $HBoxContainer/Level2
@onready var lvl3 = $HBoxContainer/Level3
@onready var level_boss: Control = $LevelBoss

static var instance


func _ready():
	var levels = [lvl1, lvl2, lvl3, level_boss]
	lvl1.generate_level(LevelData.Difficulty.EASY)
	lvl2.generate_level(LevelData.Difficulty.MEDIUM)
	lvl3.generate_level(LevelData.Difficulty.HARD)
	for level in levels:
		level.connect("wave_information", send_level_start)

# Array[Array[LogicalCharacter.TYPE]] = [[Goblin;,Skelet],[],[]]
signal start_level(level_data)


func send_level_start(level_data):
	emit_signal("start_level", level_data)
	UI.manager.hide_overlay(UI.NAME.LEVEL_SELECTION)


func regen():
	instance = self
	lvl1.generate_level(LevelData.Difficulty.EASY)
	lvl2.generate_level(LevelData.Difficulty.MEDIUM)
	lvl3.generate_level(LevelData.Difficulty.HARD)


func _on_exit_pressed() -> void:
	SoundManager.instance.play_sound("Click2", true, false)
	UI.manager.hide_overlay(UI.NAME.LEVEL_SELECTION)


func _on_exit_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_exit_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
