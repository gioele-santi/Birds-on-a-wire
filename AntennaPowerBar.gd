extends Control
class_name AntennaPowerBar

export (bool) var inverted := false setget set_inverted

func _ready() -> void:
	$TextureProgress.modulate = Color("cfa3ff")

func _on_Antenna_update_power(value) -> void:
	$TextureProgress.value = value

func set_inverted(value) -> void:
	inverted = value
	$TextureProgress.fill_mode = 1 if inverted else 0
