class_name SoundManager
extends Node

static var instance

var children_array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self

	for childs_numb: AudioStreamPlayer in get_children():
		children_array.append(childs_numb)


func play_sound(sound_name: String, play: bool, pitch_var: bool = false):
	for childs: AudioStreamPlayer in children_array:
		if sound_name == childs.name && play == false:
			if childs.playing:
				childs.stop()
			else:
				print(sound_name + " is not playing so it can't stop")

		elif sound_name == childs.name && play == true:
			if pitch_var == true:
				childs.pitch_scale = randf_range(0.8, 1.2)
			else:
				pass
			if childs.playing:
				childs.stop()
				childs.play()
			else:
				childs.play()

		else:
			pass
