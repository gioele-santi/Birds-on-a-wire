extends Control
class_name AntennaPowerBar

export (bool) var inverted := false setget set_inverted

var active_color := Color("cfa3ff") 
var inactive_color := Color("b1b1b1")

func _ready() -> void:
	$TextureProgress.modulate = active_color

func _on_Antenna_update_power(value) -> void:
	$TextureProgress.value = value
	if value <= 0:
		$TextureProgress.modulate = inactive_color
	elif value == $TextureProgress.max_value:
		$TextureProgress.modulate = active_color

func set_inverted(value) -> void:
	inverted = value
	$TextureProgress.fill_mode = 1 if inverted else 0
