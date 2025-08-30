class_name SoundManager

extends Node

static var instance

var children_array = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	for lChilds_numb: AudioStreamPlayer in get_children():
		children_array.append(lChilds_numb)
	
	

func play_sound(pSound_name:String, pPlay:bool, pPitch_var:bool = false):
	for childs: AudioStreamPlayer in children_array:
		if pSound_name == childs.name && pPlay == false:
			if childs.playing:
				childs.stop()
			else:
				print(pSound_name+" is not playing so it can't stop")
			
		elif pSound_name == childs.name && pPlay == true:
			if pPitch_var == true: childs.pitch_scale = randf_range(0.8, 1.2)
			else: pass
			
			if childs.playing:
				childs.stop()
				childs.play()
			else:
				childs.play()
				
		else:
			print(pSound_name+" doesn't match an actual sound")
