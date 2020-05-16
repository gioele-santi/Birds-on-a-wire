extends Control

func _ready() -> void:
	pass # Replace with function body.

func _on_Game_level_changed(level) -> void:
	var text = "Level " + str(level)
	$Label.text = text
	$Drop.text = text
