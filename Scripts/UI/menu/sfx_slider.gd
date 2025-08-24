extends HSlider

var bus_index: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bus_index = AudioServer.get_bus_index(self.name)# The node must be called like an audio bus
	value_changed.connect(_on_value_changed)
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))

func _on_value_changed(pValue: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(pValue))
