extends Control
class_name AntennaPowerBar

func _ready() -> void:
	$TextureProgress.modulate = Color("4e58e4")

func _on_Antenna_update_power(value) -> void:
	$TextureProgress.value = value
