extends Control

var level_data = {"WaveInfo" : [] , "Rewards" : {}}

func _ready() -> void:
	var enemy_waves = [[LogicalCharacter.TYPE.Dragon],[LogicalCharacter.TYPE.Dragon],[LogicalCharacter.TYPE.Dragon]]
	level_data["WaveInfo"] = enemy_waves
	level_data["Rewards"] = {Cookie.TYPE.Normal : 10, Cookie.pick_random_special() : 10}

signal wave_information(level_data)
func _on_button_pressed() -> void:
	SoundManager.instance.play_sound("Click1", true, true)
	emit_signal("wave_information", level_data)


func _on_button_mouse_entered() -> void:
	Cursor.instance.texture = Cursor.point


func _on_button_mouse_exited() -> void:
	Cursor.instance.texture = Cursor.basic
