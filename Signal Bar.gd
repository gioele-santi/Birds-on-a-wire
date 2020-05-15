extends Control

class_name SignalBar

func _ready() -> void:
	$TextureProgress.modulate = Color("38c055")

func _on_Game_update_connection_strength(value) -> void:
	$TextureProgress.value = value
	if value > 66:
		$TextureProgress.modulate = Color("38c055")
	elif value <= 66 and value > 33:
		$TextureProgress.modulate = Color("e6da42")
	else:
		$TextureProgress.modulate = Color("e64242")
