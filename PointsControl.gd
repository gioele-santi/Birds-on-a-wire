extends Control

func _on_Game_points_changed(points) -> void:
	var text = "%08d" % int(points)
	$Label.text = text
	$Drop.text = text
