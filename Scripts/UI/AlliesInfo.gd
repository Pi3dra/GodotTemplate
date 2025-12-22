extends Control

@onready var health_bar: TextureProgressBar = $Panel/HBoxContainer/HealthContainer/HealthBar
@onready var damage_bar: TextureProgressBar = $Panel/HBoxContainer/DamageContainer2/DamageBar
@onready var speed_bar: TextureProgressBar = $Panel/HBoxContainer/SpeeContainer3/SpeedBar
@onready var crit_bar: TextureProgressBar = $Panel/HBoxContainer/CritContainer4/CritBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
