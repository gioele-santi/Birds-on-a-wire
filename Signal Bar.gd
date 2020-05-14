extends Control

class_name SignalBar

func _ready() -> void:
	$TextureProgress.modulate = Color("359ee0")

func _on_Game_update_connection_strength(value) -> void:
	$TextureProgress.value = value
	if value > 660:
		$TextureProgress.modulate = Color("359ee0")
	elif value <= 660 and value > 330:
		$TextureProgress.modulate = Color("e6da42")
	else:
		$TextureProgress.modulate = Color("e64242")
